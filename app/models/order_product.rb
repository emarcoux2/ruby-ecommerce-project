class OrderProduct < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, :price_each, presence: true
  validates :quantity, numericality: { only_integer: true }
  validates :price_each, numericality: true
end
