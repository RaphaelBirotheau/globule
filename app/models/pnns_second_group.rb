class PnnsSecondGroup < ApplicationRecord
  has_many :pnns_products
  has_many :products, through: :pnns_products
end
