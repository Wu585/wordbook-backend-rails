require 'rails_helper'
require 'active_support/testing/time_helpers'

RSpec.describe "Me", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  describe "获取当前用户" do
    it "登录后成功获取" do
      user = User.create email: '15151851516@163.com'
      # post '/api/v1/session', params: { email: '15151851516@163.com', code: '123456' }
      get '/api/v1/me', headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["resource"]["id"]).to be_a Integer
    end
    it "jwt 过期" do
      travel_to Time.now - 3.hours
      user = User.create email: '1@qq.com'
      jwt = user.generate_jwt
      travel_back
      get '/api/v1/me', headers: {'Authorization': "Bearer #{jwt}"}
      expect(response).to have_http_status 401
    end
    it 'jwt 没过期' do
      travel_to Time.now - 1.hours
      user = User.create email: '1@qq.com'
      jwt = user.generate_jwt
      travel_back
      get '/api/v1/me', headers: {'Authorization': "Bearer #{jwt}"}
      expect(response).to have_http_status 200
    end
  end
end
