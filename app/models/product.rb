class Product < ApplicationRecord
  belongs_to :category

  has_many :cart_products
  has_many :carts, through: :cart_products

  validates :name, :quantity, :unit, :price, :is_active, presence: true
  validates :quantity, numericality: { only_integer: true }
  validates :price, numericality: true
  validates :name, uniqueness: true
end
