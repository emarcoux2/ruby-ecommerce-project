class Cart < ApplicationRecord
  belongs_to :customer
  has_many :products, through: :cart_products
end
