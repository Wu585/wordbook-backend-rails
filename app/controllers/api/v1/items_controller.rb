class Api::V1::ItemsController < ApplicationController
  def index
    current_user_id = request.env["current_user_id"]
    return head :unauthorized if current_user_id.nil?
    items = Item.where({ user_id: current_user_id })
                .where({ created_at: params[:created_after]..params[:created_before] })
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
    item = Item.new params.permit(:amount, :tags_id, :happened_at)
    item.user_id = request.env["current_user_id"]
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }, status: :unprocessable_entity
    end
  end
end
