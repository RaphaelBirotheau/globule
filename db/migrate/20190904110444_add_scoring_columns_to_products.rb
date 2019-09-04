class AddScoringColumnsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :environmental_score, :integer
    add_column :products, :health_score, :integer
    add_column :products, :social_score, :integer
  end
end
