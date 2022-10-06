class Api::V1::ItemsController < ApplicationController
  def index
    current_user_id = request.env['current_user_id']
    return head :unauthorized if current_user_id.nil?
    items = Item
      .where({user_id: current_user_id})
      .where({created_at: params[:created_after]..params[:created_brefore]})
      .page(params[:page])
    render json: { data: {
      items: items,
      page: params[:page],
      per_page: 10,
      count: Item.count
    }}
  end

  def create
    item = Item.new amount: params[:amount]
    if item.save
      render json: {data: item}
    else
      render json: {errors: item.errors}
    end
  end
end
