class CreateUserProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :user_profiles do |t|
      t.string :nutrition_score_repartition
      t.string :nutrition_repartition
      t.string :nova_repartition
      t.string :label_repartition
      t.string :packaging_repartition
      t.string :product_category_repartition
      t.string :product_sub_category_repartition
      t.string :country_origin_repartion
      t.string :additives_repartition
      t.timestamps
    end
  end
end
