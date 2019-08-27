class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :nutrition_grades_tags
      t.string :nova_group
      t.string :allergens_tags
      t.string :generic_name_fr
      t.string :image_front_url
      t.string :code
      t.string :categories_hierarchy
      t.string :additives_tags
      t.string :brands
      t.string :stores_tags
      t.string :labels_tags
      t.string :countries_tags
      t.string :ingredients_tags
      t.string :packaging_tags
      t.string :product_quantity
      t.string :serving_quantity
      t.string :ingredients_analysis_tags
      t.string :nutriments
      t.string :pnns_group_1
      t.string :pnns_group_2
      t.timestamps
    end
  end
end
