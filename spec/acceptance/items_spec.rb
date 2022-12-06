require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "账目" do
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
    let(:created_after) { '2020-05-01' }
    let(:created_before) { '2020-10-01' }
    example "获取账目" do
      user = User.create email: '1@qq.com'
      11.times { Item.create amount: 100, created_at: '2020-06-01', user_id: user.id }
      jwt = ''
      no_doc do
        client.post '/api/v1/session', email: '1@qq.com', code: '123456'
        json = JSON.parse response_body
        jwt = json["jwt"]
      end
      header 'Authorization', "Bearer #{jwt}"
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"].size).to eq 8
    end
  end
end