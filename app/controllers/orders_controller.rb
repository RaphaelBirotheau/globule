class OrdersController < ApplicationController
after_action :global_facts, only: [:create]
after_action :create_user_profile, only: [:create]


  def last
    @order = Order.last
  end

  def index
    @orders = Order.where(user: current_user)
  end

  def recommendations
    @order = Order.find(params[:id])
  end

  def create_user_profile
    UserProfile.create!(user: current_user) if !current_user.user_profile
  end

  def order_recommended_score
    @order_score = []
    @order_score << Product.total_score
  end

  def new
    @order = Order.new
  end

  def show
    @order = Order.find(params[:id])
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
    redirect_to lastbasket_path
  end

private

  def order_params
    params.require(:order).permit(:shopping_list)
  end

end
