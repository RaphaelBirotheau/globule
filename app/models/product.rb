require 'json'
require 'open-uri'

class Product < ApplicationRecord
  EU_COUNTRIES = ["albania", "andorra", "austria", "belarus", "belgium", "bosnia and herzegovina", "bulgaria", "croatia", "cyprus", "czech republic", "denmark", "estonia", "finland", "germany", "greece", "hungary", "iceland", "ireland", "italy", "kosovo", "latvia", "liechtenstein", "lithuania", "luxembourg", "macedonia", "malta", "moldova", "monaco", "montenegro", "netherlands", "norway", "poland", "portugal", "romania", "san marino", "serbia", "slovakia", "slovenia", "spain", "sweden", "switzerland", "turkey", "ukraine", "united kingdom", "vatican city", "albanie", "andorre", "autriche", "azerbaidjan", "bielorussie", "belgique", "boznie", "bulgarie", "croatie", "chypre", "tcheque", "tchequie", "danemark", "estonie", "finland", "allemagne", "deutschland", "grêce", "grece", "irlande", "italie", "estonie", "lettonie", "lituanie", "macedoine", "malte", "moldavie", "pays-bas", "norvège", "suède", "pologne", "roumanie", "serbie", "slovaquie","slovénie", "espagne", "suisse", "turquie", "royaume", "angleterre", "england", "scotland", "ecosse", "union-europeenne", "european union", "european-union", "union europeenne", "europe"]

  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_one :pnns_product
  has_one :pnns_second_group, through: :pnns_product

  validates :code, presence: true

  before_create :call_open_food_fact

  after_create :create_pnns, if: :code_not_nil?
  after_create :compute_total_score
  @dangerous_additives = ["en:e102", "en:e110", "en:e123", "en:e124", "en:e127", "en:e131", "en:e142", "en:e154", "en:e160", "en:e163", "en:e154", "en:e102", "en:e110", "en:e120", "en:e123", "en:e124", "en:e125", "en:e126", "en:e120", "en:e173", "en:e175"]
  @eu_countries = ["Albania", "Andorra", "Austria", "Azerbaijan", "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria" ,"Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "Germany", "Greece", "Hungary", "Iceland", "Ireland", "Italy", "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Macedonia", "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "San Marino", "Serbia", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Turkey", "Ukraine", "United Kingdom", "Vatican City", "Albanie", "Andorre", "Autriche", "Azerbaidjan", "Bielorussie", "Belgique", "Boznie", "Bulgarie", "Croatie", "Chypre", "Tcheque", "Tchequie", "Danemark", "Estonie", "Finland", "Allemagne", "Deutschland", "Grêce", "Grece", "Irlande", "Italie", "Estonie", "Lettonie", "Lituanie", "Macedoine", "Malte", "Moldavie", "Pays-bas", "Norvège", "Suède", "Pologne", "Roumanie", "Serbie", "Slovaquie","Slovénie", "Espagne", "Suisse", "Turquie", "Royaume", "Angleterre", "England", "Scotland", "Ecosse", "union-europeenne", "european union", "european-union", "union europeenne"]
  @france = ["France", "French", "france", "french", "fr-", "-fr", "fr:"]
  @packagings = ["Carton", "plastique", "verre", "carton", "alu", "plastic", "Verre", "Aluminium", "aluminium"]

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
    nutri_score(self.nutrition_grades_tags) + nova_score(self.nova_group) + self.additives_score +  self.label_score
  end

  def compute_environmental_score
    self.pnns_product.pnns_second_group.environmental_score + compute_label_score + self.origin_score + self.packaging_score + (nova_score(self.nova_group))

    # if has_labels_bio?(JSON.parse(self.labels_tags)) && origin_score && has_plastic?(self.packaging_tags)
    #   self.pnns_product.pnns_second_group.environmental_score + (nova_score(self.nova_group) * 2) + 50
    # elsif has_labels_bio?(JSON.parse(self.labels_tags)) && origin_score
    #   self.pnns_product.pnns_second_group.environmental_score + (nova_score(self.nova_group) * 2) + 40
    # elsif has_labels_bio?(JSON.parse(self.labels_tags))
    #   self.pnns_product.pnns_second_group.environmental_score + (nova_score(self.nova_group) * 2) + 20
    # else
    #   self.pnns_product.pnns_second_group.environmental_score + (nova_score(self.nova_group) * 2)
    # end
  end

  def social_score
    (compute_label_score * 4.6) + (self.origin_score * 1.2)
    # if has_labels_bio?(JSON.parse(self.labels_tags))
    #   50
    # elsif has_labels_bio?(JSON.parse(self.labels_tags)) && has_labels_fairtrade?(JSON.parse(self.labels_tags))
    #   75
    # elsif has_labels_bio?(JSON.parse(self.labels_tags)) && has_labels_fairtrade?(JSON.parse(self.labels_tags)) && origin_score
    #   100
    # else
    #   origin_score
    # end
  end

  def has_labels_bio?(tags)
    labels = ["bio", "organic", "ecocert"]
    tags.any? { |tag| labels.include?(tag.gsub("en:","").downcase) }

  end

  def has_labels_fairtrade?(tags)
    labels = ["fairtrade", "equitable", "fair-trade"]
    tags.any? { |tag| labels.include?(tag.gsub("en:","").downcase) }
  end

  def compute_label_score

    if has_labels_bio?(JSON.parse(self.labels_tags)) && has_labels_fairtrade?(JSON.parse(self.labels_tags))
      15
    elsif has_labels_fairtrade?(JSON.parse(self.labels_tags))
      5
    elsif has_labels_bio?(JSON.parse(self.labels_tags))
      10
    else
      0
    end
  end


  def is_french?(tags)
    countries = ["france", "europe"]
    if !tags.nil?
      if tags.start_with?('[')
        JSON.parse(tags).any? { |label| label.downcase.include?("france") }
      else
        tags.downcase.include?("france")
      end
    end
  end

  def compute_origin_score(tags)
    score = 0
    if !tags.nil?
      tags.each do |tag|
        if tag.downcase.include?('france')
          score += 25 #France
        elsif EU_COUNTRIES.include?(tag.downcase)
          score += 15 #European Union
        else # rest of the world
          score = 1 #
        end
      end
    end
    return score
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
      60
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

  def compute_additive_score(tags)
  dangerous_additives = ["en:e102", "en:e110", "en:e123", "en:e124", "en:e127", "en:e131", "en:e142", "en:e154", "en:e160", "en:e163", "en:e154", "en:e102", "en:e110", "en:e120", "en:e123", "en:e124", "en:e125", "en:e126", "en:e120", "en:e173", "en:e175"]
     if tags.count == 0
        15 #no additives, it's good
      elsif tags.any? { |tag| dangerous_additives.include?(tag.downcase) }
        0 #has at least one dangerous additive
      elsif tags.count <= 4
        10  #has four or less additives
      elsif tags.count <= 8
        5 #has 8 or less additives
      else
        1 #has more than 8 additives or company doesn't provide data
    end
  end

  def compute_packaging_score(tags)
    carton = ["plasti", "allu", "verre", "glass"]
    verre = ["plasti", "allu", "carton"]
    if tags.nil?
      0
    elsif tags.count == 0
      0
    elsif tags.kind_of?(Array)
      # product_pack =  JSON.parse(tags)
      if tags.any? { |label| label.downcase.include?("plasti") }
        1 #Cardboard only
      elsif tags.any? { |pack| verre.exclude?(pack.downcase) } && tags.any? { |label| label.downcase.include?("verre") }
        15  #Glass only
      elsif tags.any? { |pack| carton.exclude?(pack.downcase) } && tags.any? { |label| label.downcase.include?("carton") }
        20 #Contains plastic
      elsif tags.any? { |pack| verre.exclude?("plasti") } && tags.any? { |label| label.downcase.include?("allu") }
        10  #Contains aluminium
      else
        2   #Contains plastic and others
      end
    else
      if tags.downcase.include?("plasti")
        1
      elsif tags.downcase.include?("carton")
        20
      elsif tags.downcase.include?("verre")
        15
      elsif tags.downcase.include?("allu")
        10
      else
        2
      end
    end
  end


  def compute_total_score
    # order matters here!
    begin
      self.additives_score = compute_additive_score(JSON.parse(self.additives_tags))
      self.origin_score = compute_origin_score(JSON.parse(self.countries_tags))
      self.label_score = compute_label_score
      self.packaging_score = compute_packaging_score(JSON.parse(self.packaging_tags))
      self.health_score = health_score
      self.environmental_score =  compute_environmental_score
      self.social_score = social_score
      self.total_score = health_score + compute_environmental_score + social_score
      self.save
    rescue
      puts code
    end
  end

  def self.recommendation(code)
    old_product = Product.find_by(code: code)

    product_categories = JSON.parse(old_product.categories_hierarchy).reverse

    product_categories.each do |product_cat|
      product = Product.
        where.not(id: old_product.id).
        where('categories_hierarchy like ?', "%#{product_cat}%").
        where('health_score >= ?', old_product.health_score).
        where('social_score >= ?', old_product.social_score).
        where('environmental_score >= ?', old_product.environmental_score).
        order(total_score: :desc).
        first
      # return the product if found otherwise stay in the each loop
      return product if product
    end
  end


  def self.color_health(code)
    product = Product.find_by(code: code)
    if product.health_score < 20
      return "#EF3C22"
    elsif product.health_score < 40
      return "#F67F23"
    elsif product.health_score < 60
      return "#FFC82B"
    elsif product.health_score < 80
      return "#83B937"
    else
      return "#008042"
    end
  end

  def self.color_social(code)
    product = Product.find_by(code: code)
    if product.social_score < 20
      return "#EF3C22"
    elsif product.social_score < 40
      return "#F67F23"
    elsif product.social_score < 60
      return "#FFC82B"
    elsif product.social_score < 80
      return "#83B937"
    else
      return "#008042"
    end
  end

  def self.color_env(code)
    product = Product.find_by(code: code)
    if product.compute_environmental_score < 20
      return "#EF3C22"
    elsif product.compute_environmental_score < 40
      return "#F67F23"
    elsif product.compute_environmental_score < 60
      return "#FFC82B"
    elsif product.compute_environmental_score < 80
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
    elsif JSON.parse(product.additives_tags).count <= 4
      return "#FFC82B"
    elsif JSON.parse(product.additives_tags).count <= 8
      return "#F67F23"
    else
      return "#EF3C22"
    end
  end

  def self.color_country(code)
    product = Product.find_by(code: code)
    result = @eu_countries - product.countries_tags.gsub('-', ' ').split(' ')
    if @france.include?(JSON.parse(product.countries_tags).join(","))
      return "#008042"
    elsif result.length != @eu_countries.length
      return "#FFC82B"
    else
      return "#F67F23"
    end
  end

  def self.color_pack_health(code)
    product = Product.find_by(code: code)
    score = product.packaging_score
    if score == 1
      return "#EF3C22"
    elsif score == 2
      return "grey"
    else
      return "#008042"
    end
  end

   def self.color_pack(code)
    product = Product.find_by(code: code)
    score = product.additives_score
    if score == 20
      return "#008042"
    elsif score == 15
      return "#83B937"
    elsif score == 10
      return "#F67F23"
    elsif score == 1
      return "#EF3C22"
    else
      return "grey"
    end
  end


  def self.color_labels_env(code)
    product = Product.find_by(code: code)
    if product.compute_label_score == 15
      return "#008042"
    elsif product.compute_label_score == 10
      return "#83B937"
    elsif product.compute_label_score == 5
      return "#83B937"
    elsif product.compute_label_score == 0
      return "#EF3C22"
    end
  end

  def self.color_labels_health(code)
    product = Product.find_by(code: code)
    if product.compute_label_score == 15
      return "#008042"
    elsif product.compute_label_score == 10
      return "#83B937"
    elsif product.compute_label_score == 5
      return "#F67F23"
    elsif product.compute_label_score == 0
      return "#EF3C22"
    end
  end

  def self.color_labels_soc(code)
    product = Product.find_by(code: code)
    if product.compute_label_score == 15
      return "#008042"
    elsif product.compute_label_score == 5
      return "#83B937"
    elsif product.compute_label_score == 10
      return "#F67F23"
    elsif product.compute_label_score == 0
      return "#EF3C22"
    end
  end

  def self.retrieve_packs(code)
    product = Product.find_by(code: code)
    x = []
    if JSON.parse(product.packaging_tags) != nil
      JSON.parse(product.packaging_tags).each do |pack|
        if @packagings.include?(pack)
          x << pack.capitalize
        end
      end
    end
      return x.join(", ")
  end

  def self.retrieve_additives(code)
    product = Product.find_by(code: code)
      x = []
    if product.additives_tags != nil
      JSON.parse(product.additives_tags).each do |pack|
        if @dangerous_additives.include?(pack)
          x << pack.gsub("en:", "").capitalize
        end
      end
      return x.join(", ")
    end
  end
end
