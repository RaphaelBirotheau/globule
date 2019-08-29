class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def global_facts
    global_nutrition_score_array = []
    global_packaging_array = []
    global_product_category_array = []
    global_product_sub_category_array = []
    global_country_origin_repartion = []
    global_additives_array = []


    current_user.orders.each do |order|
      global_nutrition_score_array << order.nutrition_score_repartition
      global_packaging_array << order.packaging_repartition
      global_product_category_array << order.product_category_repartition
      global_product_sub_category_array << order.product_sub_category_repartition
      global_country_origin_repartion << order.country_origin_repartion
      global_additives_array << order.additives_repartition
    end

    current_user.user_profile.nutrition_score_repartition = global_nutrition_score_array
    current_user.user_profile.packaging_repartition = global_packaging_array
    current_user.user_profile.product_category_repartition = global_product_category_array
    current_user.user_profile.product_sub_category_repartition = global_product_sub_category_array
    current_user.user_profile.country_origin_repartion = global_country_origin_repartion
    current_user.user_profile.additives_repartition = global_additives_array

    current_user.user_profile.save!

  end

end
