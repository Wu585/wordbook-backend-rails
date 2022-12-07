require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "标签" do
  get "/api/v1/tags" do
    authentication :basic, :auth
    parameter :page, '页码'
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :user_id, '用户ID'
      response_field :name, '标签名'
      response_field :sign, '标签类型'
      response_field :deleted_at, '删除时间'
    end
    let(:current_user) { User.create email: '1@qq.com' }
    let(:auth) { "Bearer #{current_user.generate_jwt}" }
    example "获取标签" do
      11.times { Tag.create name: 'x', sign: 'x', user_id: current_user.id }
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"].size).to eq 10
    end
  end
end