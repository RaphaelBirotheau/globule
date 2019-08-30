class RemoveHealthScoreFromProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :health_score, :integer
    remove_column :products, :social_score, :integer
    remove_column :products, :environment_score, :integer
    remove_column :products, :total_score, :integer
  end
end
