class ProfilesController < ApplicationController


  def show
    render layout: "landing"
  end

  def dashboard
    nutrition_score
    nova_score
    render layout: "landing"
  end

  private

  def nutrition_score
    scores = current_user.orders.pluck(:nutrition_score_repartition).map { |score| JSON.parse(score) }.flatten
    scores = scores.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total }
    @nutriscores = Hash[scores.to_a.sort_by { |key, val| key }]
  end

  def nova_score
    scores = current_user.orders.pluck(:nova_repartition).map { |score| JSON.parse(score) }.flatten
    scores = scores.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total }
    @novascores = Hash[scores.to_a.sort_by { |key, val| key }]
  end
end
