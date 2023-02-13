require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "标签" do
  authentication :basic, :auth
  # let(:current_user) { User.create email: '1@qq.com' }
  let(:current_user) { create :user }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }

  get "/api/v1/tags/:id" do
    let(:tag) { Tag.create name: 'x', sign: 'x', user_id: current_user.id }
    let(:id) { tag.id }
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :user_id, '用户ID'
      response_field :name, '标签名'
      response_field :sign, '符号'
      response_field :deleted_at, '删除时间'
    end
    example "获取单个标签" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["id"]).to eq tag.id
    end
  end

  get "/api/v1/tags" do
    parameter :page, '页码'
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :user_id, '用户ID'
      response_field :name, '标签名'
      response_field :sign, '符号'
      response_field :deleted_at, '删除时间'
    end
    example "获取标签" do
      11.times { Tag.create name: 'x', sign: 'x', user_id: current_user.id }
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"].size).to eq 10
    end
  end

  get "/api/v1/tags" do
    parameter :page, '页码'
    parameter :kind, '分类', in: ['expenses', 'income']
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :user_id, '用户ID'
      response_field :name, '标签名'
      response_field :sign, '符号'
      response_field :deleted_at, '删除时间'
      response_field :kind, '分类'
    end
    let(:kind) { 'income' }
    example "根据kind获取标签" do
      11.times { Tag.create name: 'x', sign: 'x', user_id: current_user.id, kind: 'expenses' }
      6.times { Tag.create name: 'x', sign: 'x', user_id: current_user.id, kind: 'income' }
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"].size).to eq 6
    end
  end

  post "api/v1/tags" do
    parameter :name, '标签名', required: true
    parameter :sign, '标签类型', required: true
    parameter :kind, '收入/支出', required: true
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :user_id, '用户ID'
      response_field :name, '标签名'
      response_field :sign, '符号'
      response_field :kind, '收入/支出'
      response_field :deleted_at, '删除时间'
    end
    let(:name) { 'x' }
    let(:sign) { 'y' }
    let(:kind) { 'income' }
    example "创建标签" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["name"]).to eq name
      expect(json["resource"]["sign"]).to eq sign
      expect(json["resource"]["kind"]).to eq kind
    end
  end

  patch "api/v1/tags/:id" do
    let(:tag) { Tag.create name: 'x', sign: 'x', user_id: current_user.id }
    let(:id) { tag.id }
    parameter :name, '标签名'
    parameter :sign, '标签类型'
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :user_id, '用户ID'
      response_field :name, '标签名'
      response_field :sign, '符号'
      response_field :deleted_at, '删除时间'
    end
    let(:name) { "y" }
    let(:sign) { "y" }
    example "修改标签" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["name"]).to eq name
      expect(json["resource"]["sign"]).to eq sign
    end
  end

  delete "/api/v1/tags/:id" do
    let(:tag) { Tag.create name: 'x', sign: 'x', user_id: current_user.id }
    let(:id) { tag.id }
    example "删除标签" do
      do_request
      expect(status).to eq 200
    end
  end
end