require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "标签" do
  authentication :basic, :auth
  let(:current_user) { User.create email: '1@qq.com' }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }
  get "/api/v1/tags" do
    parameter :page, '页码'
    with_options :scope => :data do
      response_field :id, 'ID'
      response_field :name, "名称"
      response_field :sign, "符号"
      response_field :user_id, "用户ID"
      response_field :deleted_at, "删除时间"
    end
    example "获取标签" do
      11.times do Tag.create name: 'x', sign: 'x', user_id: current_user.id end
      do_request
      expect(status).to eq 200
      json = JSON.parse(response_body)
      expect(json['data'].size).to eq 10
    end
  end
  post "/api/v1/tags" do
    parameter :name, '名称', required: true
    parameter :sign, '符号', required: true
    with_options :scope => :data do
      response_field :id, 'ID'
      response_field :name, "名称"
      response_field :sign, "符号"
      response_field :user_id, "用户ID"
      response_field :deleted_at, "删除时间"
    end
    let(:name) { 'x' }
    let(:sign) { 'x' }
    example "创建标签" do
      do_request
      expect(status).to eq 200
      json = JSON.parse(response_body)
      expect(json['data']['name']).to eq name
      expect(json['data']['sign']).to eq sign
    end
  end
  patch "/api/v1/tags/:id" do
    let (:tag) {Tag.create name: 'x', sign: 'x', user_id: current_user.id}
    let (:id) { tag.id }
    parameter :name, '名称' 
    parameter :sign, '符号'
    with_options :scope => :data do
      response_field :id, 'ID'
      response_field :name, "名称"
      response_field :sign, "符号"
      response_field :user_id, "用户ID"
      response_field :deleted_at, "删除时间"
    end
    let(:name) { 'x' }
    let(:sign) { 'x' }
    example "修改标签" do
      do_request
      expect(status).to eq 200
      json = JSON.parse(response_body)
      expect(json['data']['name']).to eq name
      expect(json['data']['sign']).to eq sign
    end
  end
end