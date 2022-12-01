class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.page(params[:page]).per(params[:per_page])
    render json: {
      resource: items,
      count: Item.count
    }
  end

  def create
    item = Item.new amount: 1
    if item.save
      render json: { resource: item }
    end
  end
end
