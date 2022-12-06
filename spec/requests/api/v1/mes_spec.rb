require 'rails_helper'

RSpec.describe "Me", type: :request do
  describe "获取当前用户" do
    it "登录后成功获取" do
      User.create email: '15151851516@163.com'
      post '/api/v1/session', params: { email: '15151851516@163.com', code: '123456' }
      json = JSON.parse response.body
      jwt = json["jwt"]
      get '/api/v1/me', headers: { 'Authorization': "Bearer #{jwt}" }
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["resource"]["id"]).to be_a Integer
    end
  end
end
