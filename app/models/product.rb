require 'json'
require 'open-uri'

class Product < ApplicationRecord
  has_many :order_items
  has_many :orders, through: :order_items

  validates :code, presence: true

  before_create :call_open_food_fact
  # after_create :scoring

  def call_open_food_fact

    barcode = self.code
    url = "https://fr.openfoodfacts.org/api/v0/produit/#{barcode}.json"
    product_serialized = open(url).read
    product = JSON.parse(product_serialized)
    if product["status_verbose"] != "product not found"
      self.nutrition_grades_tags = product["product"]["nutrition_grades_tags"][0]
      self.nova_group = product["product"]["nova_group"]
      self.allergens_tags = product["product"]["allergens_tags"]
      self.generic_name_fr = product["product"]["product_name"]
      self.categories_hierarchy = product["product"]["categories_hierarchy"]

      self.additives_tags = product["product"]["additives_tags"]
      self.brands = product["product"]["brands"]
      self.stores_tags = product["product"]["stores_tags"]
      self.labels_tags = product["product"]["labels_tags"]
      self.countries_tags = product["product"]["countries"]
      self.ingredients_tags = product["product"]["ingredients_tags"]
      self.packaging_tags = product["product"]["packaging_tags"]
      self.product_quantity = product["product"]["product_quantity"]
      self.serving_quantity = product["product"]["serving_quantity"]
      self.ingredients_analysis_tags = product["product"]["ingredients_analysis_tags"]
      self.nutriments = product["product"]["nutriments"]
      self.pnns_group_1 = product["product"]["pnns_groups_1"]
      self.pnns_group_2 = product["product"]["pnns_groups_2"]
      self.image_front_url = product["product"]["image_front_url"]
    #   self.save
    else
      self.code = nil
    #   self.destroy
    end
    # self.remote_image_front_url_url = product["product"]
    # .select { |category| category.start_with?('en:') }[-2]

  end

  # def scoring
  # end
end
