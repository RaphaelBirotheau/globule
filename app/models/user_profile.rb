class UserProfile < ApplicationRecord
  belongs_to :user, dependent: :destroy
end

