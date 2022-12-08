require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "账目" do
  authentication :basic, :auth
  let(:current_user) { User.create email: '1@qq.com' }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }

  get "/api/v1/items" do
    parameter :page, '页码'
    parameter :per_page, '每页数量'
    parameter :created_after, '创建开始时间(筛选条件)'
    parameter :created_before, '创建终点时间(筛选条件)'
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :amount, '金额(单位：分)'
    end
    let(:per_page) { 8 }
    let(:created_after) { Time.now - 10.days }
    let(:created_before) { Time.now + 10.days }
    let(:tags) { (0..1).map { Tag.create name: "x", sign: "x", user_id: current_user.id } }
    let(:tags_id) { tags.map(&:id) }
    example "获取账目" do
      11.times { Item.create amount: 100, tags_id: tags_id, happened_at: "2018-01-01T00:00:00+08:00", user_id: current_user.id }
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"].size).to eq 8
    end
  end

  post "/api/v1/items" do
    parameter :amount, '金额(单位：分)', required: true
    parameter :kind, '类型', required: true, enum: ['expenses', 'income']
    parameter :tags_id, '标签列表(只传id)', required: true
    parameter :happened_at, '发生时间', required: true
    with_options :scope => :resource do
      response_field :id
      response_field :amount
      response_field :kind
      response_field :tags_id
      response_field :happened_at
    end
    let(:amount) { 9900 }
    let(:kind) { 'expenses' }
    let(:happened_at) { "2020-10-30T00:00:00+08:00" }
    let(:tags) { (0..1).map { Tag.create name: "x", sign: "x", user_id: current_user.id } }
    let(:tags_id) { tags.map(&:id) }
    example "创建账目" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['amount']).to eq amount
    end
  end

end