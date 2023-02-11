require 'rails_helper'

RSpec.describe "Api::V1::Tags", type: :request do
  describe "获取单个标签" do
    it '未登录获取单个标签' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: "x", sign: "x", user_id: user.id
      get "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status 401
    end
    it '登录后获取单个标签' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: "x", sign: "x", user_id: user.id
      get "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["resource"]["id"]).to eq tag.id
    end
    it '登录后获取不属于自己的单个标签' do
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      tag1 = Tag.create name: "x", sign: "x", user_id: user1.id
      tag2 = Tag.create name: "x", sign: "x", user_id: user2.id
      get "/api/v1/tags/#{tag2.id}", headers: user1.generate_auth_header
      expect(response).to have_http_status 403
    end
  end

  describe "获取标签列表" do
    it '未登录获取标签列表' do
      get '/api/v1/tags'
      expect(response).to have_http_status 401
    end
    it '登录后获取标签列表' do
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      11.times do |i|
        Tag.create name: "tag#{i}", sign: 'x', user_id: user1.id
        Tag.create name: "x", sign: 'x', user_id: user2.id
      end
      get '/api/v1/tags', headers: user1.generate_auth_header
      json = JSON.parse response.body
      expect(response).to have_http_status 200
      expect(json["resource"].size).to eq 10
      get '/api/v1/tags?page=2', headers: user1.generate_auth_header
      json = JSON.parse response.body
      expect(json["resource"].size).to eq 1
    end
    it '根据kind获取标签列表' do
      user = User.create email: '1@qq.com'
      11.times do |i|
        Tag.create name: "tag#{i}", sign: 'x', kind: 'expenses', user_id: user.id
        Tag.create name: "x", sign: 'x', kind: 'income', user_id: user.id
      end
      get '/api/v1/tags', headers: user.generate_auth_header, params: { kind: 'expenses', page: 2 }
      json = JSON.parse response.body
      expect(response).to have_http_status 200
      expect(json["resource"].size).to eq 1
    end
  end

  describe "创建标签" do
    it '未登录创建标签' do
      post '/api/v1/tags', params: { name: 'x', sign: 'x' }
      expect(response).to have_http_status 401
    end
    it '登录创建标签' do
      user = User.create email: "1@qq.com"
      post '/api/v1/tags', params: { name: 'name', sign: 'sign', kind: 'income' }, headers: user.generate_auth_header
      json = JSON.parse response.body
      expect(response).to have_http_status 200
      expect(json["resource"]["name"]).to eq "name"
      expect(json["resource"]["sign"]).to eq "sign"
      expect(json["resource"]["kind"]).to eq "income"
    end
    it '登录创建失败，因为name为空' do
      user = User.create email: "1@qq.com"
      post '/api/v1/tags', params: { sign: 'sign' }, headers: user.generate_auth_header
      json = JSON.parse response.body
      expect(response).to have_http_status 422
      expect(json["errors"]["name"][0]).to eq "必填"
    end
    it '登录创建失败，因为sign为空' do
      user = User.create email: "1@qq.com"
      post '/api/v1/tags', params: { name: 'name' }, headers: user.generate_auth_header
      json = JSON.parse response.body
      expect(response).to have_http_status 422
      expect(json["errors"]["sign"][0]).to eq "必填"
    end
  end

  describe "修改标签" do
    it '未登录修改标签' do
      user = User.create email: "1@qq.com"
      tag = Tag.create name: "x", sign: "x", user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { name: "y", sign: "y" }
      expect(response).to have_http_status 401
    end
    it '登录后修改标签' do
      user = User.create email: "1@qq.com"
      tag = Tag.create name: "x", sign: "x", user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { name: "y", sign: "y" }, headers: user.generate_auth_header
      json = JSON.parse response.body
      expect(response).to have_http_status 200
      expect(json["resource"]["name"]).to eq "y"
      expect(json["resource"]["sign"]).to eq "y"
    end
    it '登录后部分修改标签' do
      user = User.create email: "1@qq.com"
      tag = Tag.create name: "x", sign: "x", user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { sign: "y" }, headers: user.generate_auth_header
      json = JSON.parse response.body
      expect(response).to have_http_status 200
      expect(json["resource"]["name"]).to eq "x"
      expect(json["resource"]["sign"]).to eq "y"
    end
    it '登录后修改别人标签' do
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      tag1 = Tag.create name: "x", sign: "x", user_id: user1.id
      tag2 = Tag.create name: "x", sign: "x", user_id: user2.id
      patch "/api/v1/tags/#{tag2.id}", params: { name: "y", sign: "y" }, headers: user1.generate_auth_header
      expect(response).to have_http_status 403
    end
  end

  describe "删除标签" do
    it '未登录删除标签' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: "x", sign: "x", user_id: user.id
      delete "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status 401
    end
    it '登录后删除标签' do
      user = User.create email: '1@qq.com'
      tag = Tag.create name: "x", sign: "x", user_id: user.id
      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      tag.reload
      expect(tag.deleted_at).not_to eq nil
    end
    it '登录后删除别人标签' do
      user1 = User.create email: '1@qq.com'
      user2 = User.create email: '2@qq.com'
      tag1 = Tag.create name: "x", sign: "x", user_id: user1.id
      tag2 = Tag.create name: "x", sign: "x", user_id: user2.id
      delete "/api/v1/tags/#{tag2.id}", headers: user1.generate_auth_header
      expect(response).to have_http_status 403
    end
  end
end
