class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.page(params[:page]).per(params[:per_page])
    render json: {
      resource: items,
      count: Item.count
    }, status: 200
  end

  def create
    item = Item.new amount: params[:amount]
    if item.save
      render json: { resource: item }
    end
  end
end
