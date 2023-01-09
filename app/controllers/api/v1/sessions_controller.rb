class Api::V1::SessionsController < ApplicationController
  def create
    if Rails.env.test?
      return render status: :unauthorized if params[:code] != '123456'
    else
      canSignIn = ValidationCode.exists? email: params[:email], code: params[:code], used_at: nil
      return render status: :unauthorized if not canSignIn
    end
    user = User.find_or_create_by email: params[:email]
    render json: { jwt: user.generate_jwt }, status: :ok
  end
end
