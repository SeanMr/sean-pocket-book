require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "账目获取" do
    it "分页" do
      user1 = User.create email: '770899447@qq.com'
      user2 = User.create email: '2@qq.com'
      11.times {Item.create amount: 100, user_id: user1.id}
      11.times {Item.create amount: 100, user_id: user2.id}
      get '/api/v1/items', headers: user1.generate_auth_header
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['data']['items'].size).to eq(10)
      get '/api/v1/items?page=2', headers: user1.generate_auth_header
      json = JSON.parse(response.body)
      expect(json['data']['items'].size).to eq(1)
    end

    it "按时间筛选" do
      user1 = User.create email: '1@qq.com'
      item1 = Item.create amount: 100, created_at: Time.new(2018, 1, 2), user_id: user1.id
      item2 = Item.create amount: 100, created_at: Time.new(2018, 1, 2), user_id: user1.id
      item3 = Item.create amount: 200, created_at: Time.new(2018, 1, 1)
      get '/api/v1/items?created_after=2018-01-01&created_before=2018-01-02&', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['data']['items'].size).to eq(2)
      expect(json['data']['items'][0]['id']).to eq item1.id
      expect(json['data']['items'][1]['id']).to eq item2.id
    end
    it "按时间筛选(边界)" do
      user1 = User.create email: '1@qq.com'
      item3 = Item.create amount: 200, created_at: '2018-01-01', user_id: user1.id
      get '/api/v1/items?created_after=2018-01-01&created_before=2018-01-02', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['data']['items'].size).to eq(1)
    end
    it "按时间筛选(边界2)" do
      user1 = User.create email: '1@qq.com'
      item1 = Item.create amount: 200, created_at: '2018-01-01', user_id: user1.id
      item2 = Item.create amount: 200, created_at: '2019-01-01', user_id: user1.id
      get '/api/v1/items?created_before=2018-01-02', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['data']['items'].size).to eq(1)
      expect(json['data']['items'][0]['id']).to eq item1.id
    end
  end

  describe "创建账目" do
    it "未登录创建" do
      post '/api/v1/items', params: {amount: 100}
      expect(response).to have_http_status 401
    end
    it "登录创建" do
      user1 = User.create email: '1@qq.com'
      expect {
        post '/api/v1/items', params: {amount: 99, tags_id: [1,2], happen_at: '2018-01-01'}, headers: user1.generate_auth_header
      }.to change {Item.count}.by 1
      json = JSON.parse(response.body)
      expect(json['data']['id']).to be_an(Numeric)
      expect(json['data']['amount']).to eq(99)
      expect(json['data']['user_id']).to eq user1.id
      expect(json['data']['happen_at']).to eq '2018-01-01T00:00.000Z'
    end
    it "创建 amount 必填" do
      user1 = User.create email: '1@qq.com'
      post '/api/v1/items', params: {}, headers: user1.generate_auth_header
      expect(response).to have_http_status 422
      json = JSON.parse(response.body)
      expect(json['errors']['amount'][0]).to eq "can't be blank"
      expect(json['errors']['tags_id'][0]).to eq "can't be blank"
      expect(json['errors']['happen_at'][0]).to eq "can't be blank"
    end
  end
end
