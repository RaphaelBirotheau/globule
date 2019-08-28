class OrdersController < ApplicationController
  def last
  end

  def recommended
  end

  def create
    @shopping_list = ["3560070435210", "3083681055269", "5000159404259", "5900311003996"]
    @order = Order.new(user: User.first, purchase_date: Time.now)
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
  end

end
