require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "单词" do
  authentication :basic, :auth
  let(:current_user) { User.create email: '1@qq.com' }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }

  get "/api/v1/words/:id" do
    let(:word) { Word.create content: 'hi', description: '你好', user_id: current_user.id }
    let(:id) { word.id }
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :user_id, '用户ID'
      response_field :content, '单词'
      response_field :description, '释义'
      response_field :deleted_at, '删除时间'
    end
    example "获取单个单词" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["id"]).to eq word.id
    end
  end

  get "/api/v1/words" do
    parameter :page, '页码'
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :user_id, '用户ID'
      response_field :content, '单词'
      response_field :description, '释义'
      response_field :deleted_at, '删除时间'
    end
    example "获取单词列表" do
      11.times { Word.create content: 'hi', description: '你好', user_id: current_user.id }
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"].size).to eq 10
    end
  end

  post "api/v1/words" do
    parameter :content, '单词', required: true
    parameter :description, '释义', required: true
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :user_id, '用户ID'
      response_field :content, '单词'
      response_field :description, '释义'
      response_field :deleted_at, '删除时间'
    end
    let(:content) { 'hi' }
    let(:description) { '你好' }
    example "创建单词" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["content"]).to eq content
      expect(json["resource"]["description"]).to eq description
    end
  end

  patch "api/v1/words/:id" do
    let(:word) { Word.create content: 'hi', description: '你好', user_id: current_user.id }
    let(:id) { word.id }
    parameter :content, '单词'
    parameter :description, '释义'
    with_options :scope => :resource do
      response_field :id, 'ID'
      response_field :user_id, '用户ID'
      response_field :content, '单词'
      response_field :description, '释义'
      response_field :deleted_at, '删除时间'
    end
    let(:content) { "hi" }
    let(:description) { "你好" }
    example "修改单词" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json["resource"]["content"]).to eq content
      expect(json["resource"]["description"]).to eq description
    end
  end

  delete "/api/v1/words/:id" do
    let(:word) { Word.create content: 'hi', description: '你好', user_id: current_user.id }
    let(:id) { word.id }
    example "删除单词" do
      do_request
      expect(status).to eq 200
    end
  end
end