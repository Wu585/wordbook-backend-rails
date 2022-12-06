class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.where({ created_at: params[:created_after]..params[:created_before] })
                .page(params[:page]).per(params[:per_page])
    render json: {
      resource: items,
      pager: {
        page: params[:page] || 1,
        per_page: params[:per_page] || Item.default_per_page,
        count: Item.count
      }
    }, status: 200
  end

  def create
    item = Item.new amount: params[:amount]
    if item.save
      render json: { resource: item }
    end
  end
end
