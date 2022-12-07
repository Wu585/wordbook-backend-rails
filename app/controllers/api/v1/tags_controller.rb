class Api::V1::TagsController < ApplicationController
  def index
    current_user_id = request.env["current_user_id"]
    return head :unauthorized if current_user_id.nil?
    tags = Tag.where(user_id: current_user_id).page(params[:page])
    render json: {
      resource: tags,
      pager: {
        page: params[:page] || 1,
        per_page: Item.default_per_page,
        count: Tag.count
      }
    }
  end
end
