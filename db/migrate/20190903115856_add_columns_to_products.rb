class AddColumnsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :additives_score, :integer
    add_column :products, :origin_score, :integer
    add_column :products, :label_score, :integer
    add_column :products, :packaging_score, :integer
  end
end
