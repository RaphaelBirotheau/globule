class OrdersController < ApplicationController

  def last
  end

  def recommended
  end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    shopping_list = order_params[:shopping_list]
    redirect_to root_path
  end

  private

  def order_params
    params.require(:order).permit(:shopping_list)
  end
end
