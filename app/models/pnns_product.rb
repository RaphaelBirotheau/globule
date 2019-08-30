class PnnsProduct < ApplicationRecord
  belongs_to :product
  belongs_to :pnns_second_group
end
