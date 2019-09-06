class Order < ApplicationRecord
  attr_accessor :shopping_list

  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items


  def product_facts
    nutrition_score_array      = []
    packaging_array            = []
    product_category_array     = []
    product_sub_category_array = []
    country_origin_repartion   = []
    additives_array            = []
    nova_array                 = []
    label_array                = []
    order_score                = []

    products.each do | product |
      nutrition_score_array      << (product.nutrition_grades_tags.presence || 'unknown')
      packaging_array            << (product.packaging_score.presence || 'unknown')
      product_category_array     << (product.pnns_group_1.presence || 'unknown')
      product_sub_category_array << (product.pnns_group_2.presence || 'unknown')
      country_origin_repartion   << (product.origin_score.presence || 'unknown')
      additives_array            << (product.additives_score.presence || 'unknown')
      nova_array                 << (product.nova_group.presence || 'unknown')
      label_array                << (product.label_score.presence || 'unknown')
      order_score                << (product.total_score.presence || 0)
    end

    self.nutrition_score_repartition      = nutrition_score_array
    self.packaging_repartition            = packaging_array
    self.product_category_repartition     = product_category_array
    self.product_sub_category_repartition = product_sub_category_array
    self.country_origin_repartion         = country_origin_repartion
    self.additives_repartition            = additives_array
    self.nova_repartition                 = nova_array
    self.label_repartition                = label_array
    self.total_score                      = order_score.sum / order_score.count

    self.save
  end

  def compute_reco_order_score
    products = self.products.uniq.map { |product| Product.recommendation(product.code) }
                  .flatten.select { |p| p p.class == Product }
    products.pluck(:total_score).map { |s| s / 3}.reduce(:+) / products.count
  end

end
