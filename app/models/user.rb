class User < ApplicationRecord
  has_one :user_profile
  has_many :orders
  has_many :order_items, through: :orders
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
