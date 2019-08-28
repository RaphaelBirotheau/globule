class OrdersController < ApplicationController

  def last
  end

  def recommended
  end

   def new
    @order = Order.new
  end


  def create
    @order = Order.new(user: current_user, purchase_date: Time.now)
    @shopping_list = order_params[:shopping_list].gsub(" ", "").split(',')
    @shopping_list.each do |item|
      if Product.where(code: item).any?
        product = Product.where(code: item).first
      else
        product = Product.create!(code: item)
      end
      OrderItem.create(order: @order, product: product)
    end
    @order.save
    @order.product_facts
    redirect_to root_path
  end

private

  def order_params
    params.require(:order).permit(:shopping_list)
  end

end
