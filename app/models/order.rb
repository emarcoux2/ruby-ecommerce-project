class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_products
  validates :total_price, :status, :receipt_url, presence: true
end
