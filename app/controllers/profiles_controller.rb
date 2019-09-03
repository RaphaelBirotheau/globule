class ProfilesController < ApplicationController
  def profile
    render layout: "landing"
  end

  def dashboard
    nutrition_score
    nova_score
    additives_score
    labels_score
    packaging_score
    origin_score
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

  def additives_score
    legend = {
      0 => { string: 'sans additif', color: '#00AB01'},
      5 => { string: 'sans additif 5', color: '#FFCC00'},
      10 => { string: 'sans additif 10', color: '#FF6600'},
      15 => { string: 'sans additif 15', color: '#F90200'}
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
    scores = current_user.orders.pluck(:label_repartition).map { |score| JSON.parse(score) }.flatten
    scores = scores.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total }
    @labels_score = Hash[scores.to_a.sort_by { |key, val| key }]
  end

  def packaging_score
    scores = current_user.orders.pluck(:packaging_repartition).map { |score| JSON.parse(score) }.flatten
    scores = scores.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total }
    @packaging_score = Hash[scores.to_a.sort_by { |key, val| key }]
  end

  def origin_score
    scores = current_user.orders.pluck(:country_origin_repartion).map { |score| JSON.parse(score) }.flatten
    scores = scores.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total }
    @origin_score = Hash[scores.to_a.sort_by { |key, val| key }]
  end

end
