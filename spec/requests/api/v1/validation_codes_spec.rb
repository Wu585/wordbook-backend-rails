require 'rails_helper'

RSpec.describe "ValidationCodes", type: :request do
  describe "发送验证码" do
    it '验证码可以被发送' do
      post '/api/v1/validation_codes', params: { email: "15151851516@163.com" }
      expect(response).to have_http_status 200
    end
    it "发送太频繁就会返回429" do
      post '/api/v1/validation_codes', params: { email: "15151851516@163.com" }
      expect(response).to have_http_status 200
      post '/api/v1/validation_codes', params: { email: "15151851516@163.com" }
      expect(response).to have_http_status 429
    end
    it '邮箱格式不合法就返回422' do
      post '/api/v1/validation_codes', params: { email: "1" }
      expect(response).to have_http_status 422
      json = JSON.parse response.body
      expect(json['errors']['email'][0]).to eq '邮件地址格式不正确'
    end
  end
end
