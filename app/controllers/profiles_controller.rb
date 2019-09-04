class ProfilesController < ApplicationController

  def show
  end

  def dashboard
    nutrition_score
    nova_score
    additives_score
    labels_score
    packaging_score
    origin_score
    render layout: 'orders'
  end

  private

  def nutrition_score
    scores = current_user.orders.pluck(:nutrition_score_repartition).map { |score| JSON.parse(score) }.flatten
    scores = scores.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total }
    @nutriscores = Hash[scores.to_a.sort_by { |key, val| key }]
    @nutriscores_rename = @nutriscores.transform_keys{ |key| key.to_s.upcase }
  end

  def nova_score
    scores = current_user.orders.pluck(:nova_repartition).map { |score| JSON.parse(score) }.flatten
    scores = scores.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total }
    @novascores = Hash[scores.to_a.sort_by { |key, val| key }]
  end


  # def nova_score
  #   legend = {
  #     # 15 => { string: 'Contains dangerous additives', color: '#FF3C02' },
  #     # 10 => { string: 'Contains dangerous additives', color: '#FF3C02' },
  #     5 => { string: 'Contains dangerous additives', color: '#FF3C02' },
  #     4 => { string: 'Contains more than 8 additives', color: '#FF8F02' },
  #     3 => { string: 'Contains ≤8 additives', color: '#FAD000' },
  #     2 => { string: 'Contains ≤4 additives', color: '#8DC51E' },
  #     1 => { string: 'No additives', color: '#017F3D' },
  #     0 => { string: 'No additives', color: '#017F3D' }
  #   }
  #   scores = current_user.orders.pluck(:additives_repartition).map { |score| JSON.parse(score) }.flatten
  #   scores = scores.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total }
  #   novascores = Hash[scores.to_a.sort_by { |key, val| key }]
  #   @novascores = {}
  #   novascores = novascores.map do |key, value|
  #     @novascores[key] = { string: legend[key][:string], color: legend[key][:color], total: value }
  #   end
  # end

  def additives_score
    legend = {
      0 => { string: 'Contains dangerous additives', color: '#FF3C02' },
      1 => { string: 'Contains more than 8 additives', color: '#FF8F02' },
      5 => { string: 'Contains ≤8 additives', color: '#FAD000' },
      10 => { string: 'Contains ≤4 additives', color: '#8DC51E' },
      15 => { string: 'No additives', color: '#017F3D' }
    }
    scores = current_user.orders.pluck(:additives_repartition).map { |score| JSON.parse(score) }.flatten
    scores = scores.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total }
    additives_score = Hash[scores.to_a.sort_by { |key, val| key }]
    @additives_score = {}
    additives_score = additives_score.map do |key, value|
      @additives_score[key] = { string: legend[key][:string], color: legend[key][:color], total: value }
    end
  end

 def labels_score
    legend = {
      0 => { string: 'No labels', color: '#FF3C02' },
      5 => { string: 'Fairtrade label', color: '#FAD000' },
      10 => { string: 'Bio label', color: '#8DC51E' },
      15 => { string: 'Bio & Faitrade labels', color: '#017F3D' }
    }
    scores = current_user.orders.pluck(:label_repartition).map { |score| JSON.parse(score) }.flatten
    scores = scores.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total }
    labels_score = Hash[scores.to_a.sort_by { |key, val| key }]
    @labels_score = {}
    labels_score = labels_score.map do |key, value|
      @labels_score[key] = { string: legend[key][:string], color: legend[key][:color], total: value }
    end
  end


 def packaging_score
    legend = {
      1 => { string: 'Contains plastic', color: '#FF3C02' },
      2 => { string: 'Contains plastic and others', color: '#FF8F02' },
      10 => { string: 'Aluminium only', color: '#FAD000' },
      15 => { string: 'Glass only', color: '#8DC51E' },
      20 => { string: 'Cardboard only', color: '#017F3D' }
    }
    scores = current_user.orders.pluck(:packaging_repartition).map { |score| JSON.parse(score) }.flatten
    scores = scores.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total }
    packaging_score = Hash[scores.to_a.sort_by { |key, val| key }]
    @packaging_score = {}
    packaging_score = packaging_score.map do |key, value|
      @packaging_score[key] = { string: legend[key][:string], color: legend[key][:color], total: value }
    end
  end


 def origin_score
    legend = {
      0 => { string: 'No information', color: '#FF3C02' },
      1 => { string: 'Rest of the World', color: '#FF8F02' },
      15 => { string: 'European Union', color: '#FAD000' },
      20 => { string: 'Origin France & border countries', color: '#8DC51E' },
      25 => { string: 'Origin France', color: '#017F3D' },
      26 => { string: 'Origin France', color: '#017F3D' }
    }
    scores = current_user.orders.pluck(:country_origin_repartion).map { |score| JSON.parse(score) }.flatten
    scores = scores.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total }
    origin_score = Hash[scores.to_a.sort_by { |key, val| key }]
    @origin_score = {}
    origin_score = origin_score.map do |key, value|
      @origin_score[key] = { string: legend[key][:string], color: legend[key][:color], total: value }
    end
  end
end

