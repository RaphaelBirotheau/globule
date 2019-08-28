class Order < ApplicationRecord
  belongs_to :user, dependent: :destroy
  has_many :order_items
  has_many :products, through: :order_items

  def product_facts
      nutrition_score_array = []
      packaging_array = []
      product_category_array = []
      product_sub_category_array = []
      country_origin_repartion = []
      additives_array = []

    self.products.each do | product |
      nutrition_score_array << Product.where(code: product[:code]).first.nutrition_grades_tags
      packaging_array << Product.where(code: product[:code]).first.nutrition_grades_tags
      product_category_array << Product.where(code: product[:code]).first.pnns_group_1
      product_sub_category_array << Product.where(code: product[:code]).first.nutrition_grades_tags
      country_origin_repartion << Product.where(code: product[:code]).first.nutrition_grades_tags
      additives_array << Product.where(code: product[:code]).first.additives_tags
    end

    self.nutrition_score_repartition = nutrition_score_array
    self.packaging_repartition = packaging_array
    self.product_category_repartition = product_category_array
    self.product_sub_category_repartition = product_sub_category_array
    self.country_origin_repartion = country_origin_repartion
    self.additives_repartition = additives_array
    self.save
  end

end
