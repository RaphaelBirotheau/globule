class Order < ApplicationRecord
  attr_accessor :shopping_list

  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items


  def product_facts
      nutrition_score_array = []
      packaging_array = []
      product_category_array = []
      product_sub_category_array = []
      country_origin_repartion = []
      additives_array = []
      nova_array = []
      label_array = []

    self.products.each do | product |
      current_product = Product.where(code: product[:code])
      nutrition_score_array << current_product.first.nutrition_grades_tags
      packaging_array << current_product.first.packaging_score
      product_category_array << current_product.first.pnns_group_1
      product_sub_category_array << current_product.first.pnns_group_2
      country_origin_repartion << current_product.first.origin_score
      additives_array << current_product.first.additives_score
      nova_array << current_product.first.nova_group
      label_array << current_product.first.label_score
    end

    self.nutrition_score_repartition = nutrition_score_array
    self.packaging_repartition = packaging_array
    self.product_category_repartition = product_category_array
    self.product_sub_category_repartition = product_sub_category_array
    self.country_origin_repartion = country_origin_repartion
    self.additives_repartition = additives_array
    self.nova_repartition = nova_array
    self.label_repartition = label_array
    self.save
  end
end
