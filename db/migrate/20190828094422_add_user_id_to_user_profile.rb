class AddUserIdToUserProfile < ActiveRecord::Migration[5.2]
  def change
    add_reference :user_profiles, :user
  end
end
