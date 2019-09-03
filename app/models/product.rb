require 'json'
require 'open-uri'

class Product < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_one :pnns_product
  has_one :pnns_second_group, through: :pnns_product

  validates :code, presence: true

  before_create :call_open_food_fact
  after_create :create_pnns, if: :code_not_nil?
  after_create :total_score_compute
  # after_create :scoring

  def call_open_food_fact

    barcode = self.code
    url = "https://fr.openfoodfacts.org/api/v0/produit/#{barcode}.json"
    product_serialized = open(url).read
    product = JSON.parse(product_serialized)
    if (product["status_verbose"] != "product not found")
      if  (PnnsSecondGroup.distinct.pluck(:name).exclude?(product["product"]["pnns_groups_2"]))
        self.code = nil
      else
        self.nutrition_grades_tags = product["product"]["nutrition_grades_tags"][0]
        self.nova_group = product["product"]["nova_group"]
        self.allergens_tags = product["product"]["allergens_tags"]
        self.generic_name_fr = product["product"]["product_name"]
        self.categories_hierarchy = product["product"]["categories_hierarchy"].select { |category| category.start_with?('en:') }
        self.additives_tags = product["product"]["additives_tags"]
        self.brands = product["product"]["brands"]
        self.stores_tags = product["product"]["stores_tags"]
        self.labels_tags = product["product"]["labels_tags"]
        self.countries_tags = product["product"]["origins_tags"]
        self.ingredients_tags = product["product"]["ingredients_tags"]
        self.packaging_tags = product["product"]["packaging_tags"]
        self.product_quantity = product["product"]["product_quantity"]
        self.serving_quantity = product["product"]["serving_quantity"]
        self.ingredients_analysis_tags = product["product"]["ingredients_analysis_tags"]
        self.nutriments = product["product"]["nutriments"]
        self.pnns_group_1 = product["product"]["pnns_groups_1"]
        self.pnns_group_2 = product["product"]["pnns_groups_2"]
        self.image_front_url = product["product"]["image_front_url"]
      end
    #   self.save
    else
      self.code = nil
    #   self.destroy
    end
    # self.remote_image_front_url_url = product["product"]
    #
  end

  def code_not_nil?
    self.code != nil
  end

  def create_pnns
    # if self.code != nil
      PnnsProduct.create!(product: self, pnns_second_group: PnnsSecondGroup.find_by(name: self.pnns_group_2))
    # end
  end

  def health_score
    if self.pnns_group_2 == "unknown"
      nutri_score(self.nutrition_grades_tags) + nova_score(self.nova_group)
    elsif has_labels_bio?(JSON.parse(self.labels_tags))
      nutri_score(self.nutrition_grades_tags) + nova_score(self.nova_group) + additive_score(JSON.parse(self.additives_tags)) + 10
    else
      nutri_score(self.nutrition_grades_tags) + nova_score(self.nova_group) + additive_score(JSON.parse(self.additives_tags))
    end
  end

  def compute_environmental_score
    if has_labels_bio?(JSON.parse(self.labels_tags)) && is_french?(self.countries_tags) && has_plastic?(self.packaging_tags)
      self.pnns_product.pnns_second_group.environmental_score + (nova_score(self.nova_group)*2) + 50
    elsif has_labels_bio?(JSON.parse(self.labels_tags)) && is_french?(self.countries_tags)
      self.pnns_product.pnns_second_group.environmental_score + (nova_score(self.nova_group)*2) + 40
    elsif has_labels_bio?(JSON.parse(self.labels_tags))
      self.pnns_product.pnns_second_group.environmental_score + (nova_score(self.nova_group)*2) + 20
    else
      2
    end
  end

  def social_score
    if has_labels_bio?(JSON.parse(self.labels_tags))
      50
    elsif has_labels_bio?(JSON.parse(self.labels_tags)) && has_labels_fairtrade?(JSON.parse(self.labels_tags))
      75
    elsif has_labels_bio?(JSON.parse(self.labels_tags)) && has_labels_fairtrade?(JSON.parse(self.labels_tags)) && is_french?(self.countries_tags)
      100
    elsif is_french?(self.countries_tags)
      25
    else
    0
    end
  end

  def has_labels_bio?(tags)
    labels = ["bio", "organic"]
    tags.any? { |tag| labels.include?(tag.gsub("en:","").downcase) }
  end

    def has_labels_fairtrade?(tags)
    labels = ["fairtrade", "equitable"]
    tags.any? { |tag| labels.include?(tag.gsub("en:","").downcase) }
  end


  def is_french?(tags)
    countries = ["france", "europe"]
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


  def nutri_score(nutri)
    if nutri.nil?
      0
    elsif nutri == "a"
      50
    elsif nutri == "b"
      45
    elsif nutri == "c"
      30
    elsif nutri == "d"
      15
    else
      0
    end
  end

  def nova_score(nova)
     if nova.nil?
      0
    elsif nova == "1"
      10
    elsif nova == "2"
      6
    elsif nova == "3"
      3
    elsif nova == "4"
      0
    else
      0
    end
  end

  def additive_score(tags)
  dangerous_additives = ["en:e102", "en:e110", "en:e123", "en:e124", "en:e127", "en:e131", "en:e142", "en:e154", "en:e160", "en:e163", "en:e154", "en:e102", "en:e110", "en:e120", "en:e123", "en:e124", "en:e125", "en:e126", "en:e120", "en:e173", "en:e175"]
     if tags.count == 0
      15
    elsif tags.include?(dangerous_additives)
      0
    elsif tags.count <= 4
      10
    elsif tags.count <= 8
      5
    else
      0
    end
  end


  def total_score_compute
    self.total_score = health_score + compute_environmental_score
    self.save
  end

  def score_cap(score)
    if score > 5
      5
    elsif score < -5
      -5
    else
      score
    end
  end

  def self.recommendation(code)
    product = Product.find_by(code: code)
    product_cat = JSON.parse(product.categories_hierarchy).reverse.first

    Product.
      where.not(id: product.id).
      where('categories_hierarchy like ?', "%#{product_cat}%").
      where('total_score >= ?', product.total_score).
      order(total_score: :desc).
      first
  end
end
