class AddColumnToPnnsSecondGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :pnns_second_groups, :group_icon, :string
  end
end
