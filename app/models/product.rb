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
  @dangerous_additives = ["en:e102", "en:e110", "en:e123", "en:e124", "en:e127", "en:e131", "en:e142", "en:e154", "en:e160", "en:e163", "en:e154", "en:e102", "en:e110", "en:e120", "en:e123", "en:e124", "en:e125", "en:e126", "en:e120", "en:e173", "en:e175"]
  @eu_countries = ["Albania", "Andorra", "Austria", "Azerbaijan", "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria" ,"Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "Germany", "Greece", "Hungary", "Iceland", "Ireland", "Italy", "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Macedonia", "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "San Marino", "Serbia", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey", "Ukraine", "United Kingdom", "Vatican City", "Albanie", "Andorre", "Autriche", "Azerbaidjan", "Bielorussie", "Belgique", "Boznie", "Bulgarie", "Croatie", "Chypre", "Tcheque", "Tchequie", "Danemark", "Estonie", "Finland", "Allemagne", "Deutschland", "Grêce", "Grece", "Irlande", "Italie", "Estonie", "Lettonie", "Lituanie", "Macedoine", "Malte", "Moldavie", "Pays-bas", "Norvège", "Suède", "Pologne", "Roumanie", "Serbie", "Slovaquie","Slovénie", "Espagne", "Suisse", "Turquie", "Royaume", "Angleterre", "England", "Scotland", "Ecosse", "union-europeenne", "european union", "european-union", "union europeenne"]
  @france = ["France", "French", "france", "french", "fr-", "-fr", "fr:"]

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

  def self.color_health(code)
    product = Product.find_by(code: code)
    if product.health_score < -3
      return "#EF3C22"
    elsif product.health_score < -1
      return "#F67F23"
    elsif product.health_score < 2
      return "#FFC82B"
    elsif product.health_score < 4
      return "#83B937"
    else
      return "#008042"
    end
  end

  def self.color_social(code)
    product = Product.find_by(code: code)
    if product.social_score < -3
      return "#EF3C22"
    elsif product.social_score < -1
      return "#F67F23"
    elsif product.social_score < 2
      return "#FFC82B"
    elsif product.social_score < 4
      return "#83B937"
    else
      return "#008042"
    end
  end

  def self.color_env(code)
    product = Product.find_by(code: code)
    if product.environmental_score < -3
      return "#EF3C22"
    elsif product.environmental_score < -1
      return "#F67F23"
    elsif product.environmental_score < 2
      return "#FFC82B"
    elsif product.environmental_score < 4
      return "#83B937"
    else
      return "#008042"
    end
  end


  def self.color_nutriscore(code)
    product = Product.find_by(code: code)
    if product.nutrition_grades_tags == "e"
      return "#EF3C22"
    elsif product.nutrition_grades_tags == "d"
      return "#F67F23"
    elsif product.nutrition_grades_tags == "c"
      return "#FFC82B"
    elsif product.nutrition_grades_tags == "b"
      return "#83B937"
    else
      return "#008042"
    end
  end

  def self.color_additives(code)
    product = Product.find_by(code: code)
    if JSON.parse(product.additives_tags).count == 0
      return "#008042"
    elsif JSON.parse(product.additives_tags).count == 1
      return "#83B937"
    elsif JSON.parse(product.additives_tags).count == 2
      return "#FFC82B"
    elsif JSON.parse(product.additives_tags).count == 3
      return "#F67F23"
    else
      return "#EF3C22"
    end
  end

  def self.color_additives_health(code)
    product = Product.find_by(code: code)
    verif = false
    JSON.parse(product.additives_tags).each do |add|
      if @dangerous_additives.include?(add)
        verif = true
      end
    end
    if verif == true
      return "#EF3C22"
    elsif JSON.parse(product.additives_tags).count == 0
      return "#008042"
    elsif JSON.parse(product.additives_tags).count == 1
      return "#83B937"
    elsif JSON.parse(product.additives_tags).count == 2
      return "#FFC82B"
    elsif JSON.parse(product.additives_tags).count == 3
      return "#F67F23"
    else
      return "#EF3C22"
    end
  end

  def self.color_country(code)
    product = Product.find_by(code: code)
    result = @eu_countries - product.countries_tags.gsub('-', ' ').split(' ')
    if @france.include?(product.countries_tags.gsub(",", " "))
      return "#008042"
    elsif result.length != @eu_countries.length
      return "#FFC82B"
    else
      return "#F67F23"
    end
  end

  def self.color_pack(code)
    product = Product.find_by(code: code)
    x = false
    JSON.parse(product.packaging_tags).each do |pack|
      if pack.include?("plasti")
        x = true
      end
    end
    if x = true
      return "#EF3C22"
    else "#FFC82B"
      return
    end
  end


  def self.color_labels(code)
    product = Product.find_by(code: code)
    label_score = 0
    JSON.parse(product.labels_tags).each do |add|
      if add.match("agriculture")
        label_score += 1
      elsif add.match("fair")
        label_score += 1
      else
        label_score = label_score
      end
    end
    if label_score > 2
      return "#008042"
    elsif label_score > 0
      return "#FFC82B"
    else
      return "#EF3C22"
    end
  end

  def self.color_labels_soc(code)
        product = Product.find_by(code: code)
    label_score = 0
    JSON.parse(product.labels_tags).each do |add|
      if add.match("agriculture")
        label_score += 1
      elsif add.match("fair")
        label_score += 1
      else
        label_score = label_score
      end
    end
    if label_score > 3
      return "#008042"
    elsif label_score > 1
      return "#FFC82B"
    else
      return "#EF3C22"
    end
  end
end
