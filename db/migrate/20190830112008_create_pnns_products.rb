class CreatePnnsProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :pnns_products do |t|
      t.references :product, foreign_key: true
      t.references :pnns_second_group, foreign_key: true

      t.timestamps
    end
  end
end
