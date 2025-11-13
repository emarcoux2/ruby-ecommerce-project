class OrderProduct < ApplicationRecord
  belongs_to :order

  validates :quantity, :price_each, presence: true
  validates :quantity, numericality: { only_integer: true }
  validates :price_each, numericality: true
end
