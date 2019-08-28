class AddFamilyColumnsToUserProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :user_profiles, :family_size, :integer
    add_column :user_profiles, :children, :integer
    add_column :user_profiles, :loyalty, :string
    add_column :user_profiles, :city, :string
  end
end
