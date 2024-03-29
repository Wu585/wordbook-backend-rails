class Api::V1::ItemsController < ApplicationController
  def index
    current_user_id = request.env["current_user_id"]
    return head :unauthorized if current_user_id.nil?
    items = Item.where({ user_id: current_user_id })
                .where({ happened_at: params[:happened_after]..params[:happened_before] })
    items = items.where(kind: params[:kind]) unless params[:kind].nil?
    count = items.count
    items = items.page(params[:page]).per(params[:per_page])
    render json: {
      resource: items,
      pager: {
        page: params[:page] || 1,
        per_page: params[:per_page] || Item.default_per_page,
        count: count
      }
    }, methods: :tags
  end

  def create
    item = Item.new params.permit(:amount, :happened_at, :kind, tags_id: [])
    item.user_id = request.env["current_user_id"]
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }, status: :unprocessable_entity
    end
  end

  def balance
    current_user_id = request.env["current_user_id"]
    return head :unauthorized if current_user_id.nil?
    items = Item.where({ user_id: current_user_id })
                .where({ happened_at: params[:happened_after]..params[:happened_before] })
    income_items = []
    expenses_items = []
    items.each do |item|
      if item.kind == 'income'
        income_items << item
      else
        expenses_items << item
      end
    end
    income = income_items.sum(&:amount)
    expenses = expenses_items.sum(&:amount)
    render json: {
      income: income,
      expenses: expenses,
      balance: income - expenses
    }
  end

  def summary
    hash = Hash.new
    # hash : {}
    items = Item.where(user_id: request.env["current_user_id"])
                .where(kind: params[:kind])
                .where(happened_at: params[:happened_after]..params[:happened_before])
    tags = []
    items.each do |item|
      if params[:group_by] == 'happened_at'
        key = item.happened_at.in_time_zone('Beijing').strftime('%F')
        hash[key] ||= 0
        hash[key] += item.amount
      else
        item.tags_id.each do |tag_id|
          tags += item.tags
          key = tag_id
          hash[key] ||= 0
          hash[key] += item.amount
        end
      end
    end
    groups = hash.map { |key, value| { "#{params[:group_by]}": key, tag: tags.find { |tag| tag.id == key }, amount: value } }
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
