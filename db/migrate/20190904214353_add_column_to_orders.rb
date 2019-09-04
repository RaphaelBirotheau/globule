class AddColumnToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :total_score, :integer
  end
end
