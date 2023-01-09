class Api::V1::WordsController < ApplicationController
  def show
    word = Word.find params[:id]
    return head 403 unless word.user_id == request.env["current_user_id"]
    render json: { resource: word }
  end

  def index
    current_user_id = request.env["current_user_id"]
    return head 401 if current_user_id.nil?
    words = Word.where(user_id: current_user_id).page(params[:page])
    render json: {
      resource: words,
      pager: {
        page: params[:page] || 1,
        count: words.count
      }
    }
  end

  def create
    current_user_id = request.env["current_user_id"]
    return head 401 if current_user_id.nil?
    word = Word.new content: params[:content], description: params[:description], user_id: current_user_id
    if word.save
      render json: { resource: word }, status: :ok
    else
      render json: { errors: word.errors }, status: :unprocessable_entity
    end
  end

  def update
    word = Word.find params[:id]
    return head 403 unless word.user_id == request.env["current_user_id"]
    word.update params.permit(:content, :description)
    if word.errors.empty?
      render json: { resource: word }
    else
      render json: { errors: word.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    word = Word.find params[:id]
    return head 403 unless word.user_id == request.env["current_user_id"]
    word.deleted_at = Time.now
    if word.save
      head 200
    else
      render json: {
        errors: word.errors
      }, status: :unprocessable_entity
    end
  end
end
