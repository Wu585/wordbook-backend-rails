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

  def create
    current_user_id = request.env["current_user_id"]
    return head :unauthorized if current_user_id.nil?
    tag = Tag.new name: params[:name], sign: params[:sign], user_id: current_user_id
    if tag.save
      render json: { resource: tag }, status: :ok
    else
      render json: { errors: tag.errors }, status: :unprocessable_entity
    end
  end

  def update
    tag = Tag.find params[:id]
    tag.update params.permit(:name, :sign)
    if tag.errors.empty?
      render json: { resource: tag }
    else
      render json: { errors: tag.errors }, status: :unprocessable_entity
    end
  end
end
