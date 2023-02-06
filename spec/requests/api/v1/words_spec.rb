require 'rails_helper'

RSpec.describe "Words", type: :request do
  describe "获取单个单词" do
    it '未登录获取单个单词' do
      user = User.create email: '1@qq.com'
      word = Word.create content: 'hello', description: '你好', user_id: user.id
      get "/api/v1/words/#{word.id}"
      expect(response).to have_http_status 401
    end
    it '登录后获取单个单词' do
      user = User.create email: '1@qq.com'
      word = Word.create content: 'hello', description: '你好', user_id: user.id
      get "/api/v1/words/#{word.id}", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json['resource']['id']).to eq word.id
    end
    it '登录后获取不属于自己的单个单词' do
      user1 = User.create email: '1@qq.com'
      word1 = Word.create content: 'hello', description: '你好', user_id: user1.id
      user2 = User.create email: '1@qq.com'
      word2 = Word.create content: 'hello', description: '你好', user_id: user2.id
      get "/api/v1/words/#{word1.id}", headers: user2.generate_auth_header
      expect(response).to have_http_status 403
    end
  end

  describe "获取单词列表" do
    it '未登录获取单词列表' do
      get '/api/v1/words'
      expect(response).to have_http_status 401
    end
    it '登录后获取单词列表' do
      user = User.create email: '1@qq.com'
      11.times do
        Word.create content: 'hello', description: '你好', user_id: user.id
      end
      get '/api/v1/words', headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse response.body
      expect(json["resource"].size).to eq 10
      get '/api/v1/words?page=2', headers: user.generate_auth_header
      json = JSON.parse response.body
      expect(json["resource"].size).to eq 1
    end
  end

  describe '创建单个单词' do
    it '未登录创建单词' do
      post '/api/v1/words', params: { content: "hi", description: '你好' }
      expect(response).to have_http_status 401
    end
    it '登录创建标签' do
      user = User.create email: '1@qq.com'
      post '/api/v1/words', params: { content: "hi", description: '你好' }, headers: user.generate_auth_header
      json = JSON.parse response.body
      expect(response).to have_http_status 200
      expect(json["resource"]["content"]).to eq "hi"
      expect(json["resource"]["description"]).to eq "你好"
    end
    it '登录创建失败，因为content为空' do
      user = User.create email: '1@qq.com'
      post '/api/v1/words', params: { description: '你好' }, headers: user.generate_auth_header
      json = JSON.parse response.body
      expect(response).to have_http_status 422
      expect(json["errors"]["content"][0]).to eq "必填"
    end
    it '登录创建失败，因为descrption为空' do
      user = User.create email: '1@qq.com'
      post '/api/v1/words', params: { content: 'hi' }, headers: user.generate_auth_header
      json = JSON.parse response.body
      expect(response).to have_http_status 422
      expect(json["errors"]["description"][0]).to eq "必填"
    end
  end

  describe '修改单个单词' do
    it '未登录修改单词 ' do
      user = User.create email: "1@qq.com"
      word = Word.create content: "hello", description: "你好", user_id: user.id
      patch "/api/v1/words/#{word.id}", params: { content: "hello", description: '你好' }
      expect(response).to have_http_status 401
    end
    it '登录后修改单个单词' do
      user = User.create email: "1@qq.com"
      word = Word.create content: "hello", description: "你好", user_id: user.id
      patch "/api/v1/words/#{word.id}", params: { content: "good", description: '很好' }, headers: user.generate_auth_header
      json = JSON.parse response.body
      expect(response).to have_http_status 200
      expect(json["resource"]["content"]).to eq "good"
      expect(json["resource"]["description"]).to eq "很好"
    end
    it '登录后部分修改单词' do
      user = User.create email: "1@qq.com"
      word = Word.create content: "hello", description: "你好", user_id: user.id
      patch "/api/v1/words/#{word.id}", params: { description: '很好' }, headers: user.generate_auth_header
      json = JSON.parse response.body
      expect(response).to have_http_status 200
      expect(json["resource"]["content"]).to eq "hello"
      expect(json["resource"]["description"]).to eq "很好"
    end
    it '登录后修改别人单词' do
      user1 = User.create email: "1@qq.com"
      user2 = User.create email: "2@qq.com"
      word1 = Word.create content: "hello", description: "你好", user_id: user1.id
      word2 = Word.create content: "hi", description: "你好", user_id: user2.id
      patch "/api/v1/words/#{word1.id}", params: { description: '很好' }, headers: user2.generate_auth_header
      expect(response).to have_http_status 403
    end
  end

  describe '删除单个单词' do
    it '未登录删除单个单词' do
      user = User.create email: "1@qq.com"
      word = Word.create content: "hello", description: "你好", user_id: user.id
      delete "/api/v1/words/#{word.id}"
      expect(response).to have_http_status 401
    end
    it '登录后删除单个单词' do
      user = User.create email: "1@qq.com"
      word = Word.create content: "hello", description: "你好", user_id: user.id
      delete "/api/v1/words/#{word.id}", headers: user.generate_auth_header
      expect(response).to have_http_status 200
      word.reload
      expect(word.deleted_at).not_to eq nil
    end
    it '登录后删除其他用户的标签' do
      user1 = User.create email: "1@qq.com"
      user2 = User.create email: "2@qq.com"
      word1 = Word.create content: "hello", description: "你好", user_id: user1.id
      word2 = Word.create content: "hi", description: "你好", user_id: user2.id
      delete "/api/v1/words/#{word1.id}", headers: user2.generate_auth_header
      expect(response).to have_http_status 403
    end
  end
end
