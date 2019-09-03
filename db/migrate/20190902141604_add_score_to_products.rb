class AddScoreToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :total_score, :integer
  end
end
