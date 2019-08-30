class AddColumnsToPoducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :health_score, :integer
    add_column :products, :environment_score, :integer
    add_column :products, :social_score, :integer
    add_column :products, :total_score, :integer
  end
end
