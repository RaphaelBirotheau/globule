require 'json'
require 'open-uri'

class Product < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_one :pnns_product
  has_one :pnns_second_group, through: :pnns_product

  validates :code, presence: true

  before_create :call_open_food_fact
  after_create :create_pnns
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
      self.categories_hierarchy = product["product"]["categories_hierarchy"].select { |category| category.start_with?('en:') }[-1]

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
    #
  end

  def create_pnns
    PnnsProduct.create!(product: self, pnns_second_group: PnnsSecondGroup.find_by(name: self.pnns_group_2))
  end

  def health_score

    if has_labels?(JSON.parse(self.labels_tags)) && (JSON.parse(self.additives_tags).any?) && has_plastic?(JSON.parse(self.packaging_tags))
      pnns_second_group.health_score + 6
    elsif has_labels?(JSON.parse(self.labels_tags)) && (JSON.parse(self.additives_tags).any?)
      pnns_second_group.health_score + 4
    elsif has_labels?(JSON.parse(self.labels_tags))
      pnns_second_group.health_score + 2
    else
      pnns_second_group.health_score
    end
  end

  def environmental_score
    if has_labels?(JSON.parse(self.labels_tags)) && is_french?(self.countries_tags) && has_plastic?(self.packaging_tags)
      pnns_second_group.environmental_score + 6
    elsif has_labels?(JSON.parse(self.labels_tags)) && is_french?(self.countries_tags)
      pnns_second_group.environmental_score + 4
    elsif has_labels?(JSON.parse(self.labels_tags))
      pnns_second_group.environmental_score + 2
    else
      pnns_second_group.environmental_score
    end
  end

  def social_score
    if self.countries_tags.downcase.include?("france")
      2
    elsif (self.countries_tags.downcase.include?("france")) && (JSON.parse(self.labels_tags).any? {|label| label.downcase.include? "bio" || "equitable" || "organic" || "fairtrade"})
      4
    else
      0
    end
  end

  def has_labels?(tags)
    labels = ["bio", "organic", "fairtrade", "equitable"]
    tags.any? { |label| labels.include?(label) }
  end

  def is_french?(tags)
    if tags.start_with?('[')
      JSON.parse(tags).any? { |label| label.downcase.include?("france") }
    else
      tags.downcase.include?("france")
    end
  end


   def has_plastic?(tags)
    if tags.start_with?('[')
      JSON.parse(tags).any? { |label| label.downcase.include?("plasti") }
    else
      tags.downcase.include?("plasti")
    end
  end

  def total_score
    social_score + environmental_score + health_score
  end

  def score_cap(score)
    if score > 5
      5
    elsif score < -5
      -5
    else
      scoreexi
    end
  end

  def self.recommendation(code)
    product = Product.find_by(code: code)
    Product.select do |p|
      p != product &&
        p.pnns_group_2 == product.pnns_group_2 &&
        p.health_score >= product.health_score
    end.sort_by(&:total_score).first
  end

  # def set_scores
  #   self.health_score = pnns_second_group.health_score
  #   self.environmental_score = ""
  #   pnns_second_group.environmental_score
  #   self.health_score = pnns_second_group.health_score
  #   save!
  # end

  # def scoring
  # end
end
