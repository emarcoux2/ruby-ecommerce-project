class Order < ApplicationRecord
  belongs_to :customer

  has_many :order_products
  has_many :product, through: :order_products

  validates :total_price, :status, :receipt_url, presence: true
  validates :total_price, numericality: true
end
