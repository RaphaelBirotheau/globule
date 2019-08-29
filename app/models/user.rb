class User < ApplicationRecord
  after_commit :create_user_profile

  has_one :user_profile, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :order_items, through: :orders
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
