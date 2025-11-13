class OrderProduct < ApplicationRecord
  belongs_to :order
  validates :quantity, :price_each, presence: true
end
