class CreatePnnsSecondGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :pnns_second_groups do |t|
      t.string :name
      t.float :health_score
      t.float :environmental_score

      t.timestamps
    end
  end
end
