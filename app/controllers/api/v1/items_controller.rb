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
    item = Item.new params.permit(:amount, :happened_at, tags_id: [])
    item.user_id = request.env["current_user_id"]
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }, status: :unprocessable_entity
    end
  end

  def summary
    hash = Hash.new
    # hash : {}
    items = Item.where(user_id: request.env["current_user_id"])
                .where(kind: params[:kind])
                .where(happened_at: params[:happened_after]..params[:happened_before])
    items.each do |item|
      if params[:group_by] == 'happened_at'
        key = item.happened_at.in_time_zone('Beijing').strftime('%F')
        hash[key] ||= 0
        hash[key] += item.amount
      else
        item.tags_id.each do |tag_id|
          key = tag_id
          hash[key] ||= 0
          hash[key] += item.amount
        end
      end
    end
    groups = hash.map { |key, value| { "#{params[:group_by]}": key, amount: value } }
    if params[:group_by] == 'happened_at'
      groups.sort! { |a, b| a[:happened_at] <=> b[:happened_at] }
    elsif params[:group_by] == 'tag_id'
      groups.sort! { |a, b| b[:amount] <=> a[:amount] }
    end
    render json: {
      resource: groups,
      total: items.sum(:amount)
    }
  end
end
