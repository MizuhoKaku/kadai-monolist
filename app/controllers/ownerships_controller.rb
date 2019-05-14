class OwnershipsController < ApplicationController
  def create
    @item = Item.find_or_initialize_by(code: params[:item_code])
    
    # @item.persisted? -> DBに保存されているか
    # されているなら true
    # されてない     false
    unless @item.persisted?
      results = RakutenWebService::Ichiba::Item.search(itemCode: @item.code)
      
      @item = Item.new(read(results.first))
      # ここで初めて id が採番される
      @item.save
    end
  
    if params[:type] == 'Want'
      # このメソッドが実行される時点では
      # ownershops テーブルに必要な item_id と user_id がそろっている
      current_user.want(@item)
      # def want(item)
      #     items テーブルの主キーを使って検索する
      #     検索した結果、なければレコードを作成する
      #     self.wants.find_or_create_by(item_id: item.id)
      # end
      flash[:success] = '商品をWantしました'
    else
      current_user.have(@item)
      flash[:success] = '商品をHaveしました'
    end
  
    redirect_back(fallback_location: root_path)
  end  

  def destroy
    # @item = Item.find(params[:item_code]) でもOK
    # ただし、画面からitem_codeをおくってください
    # @item = Item.find(params[:item_code])
    @item = Item.find(params[:item_id])
    
    if params[:type] =='Want'
      current_user.unwant(@item)
      flash[:success] = '商品のWantを解除しました'
    else  
      current_user.unhave(@item)
      flash[:success] = '商品のHaveを解除しました'
    end
    
    redirect_back(fallback_location: root_path)
  end

end
