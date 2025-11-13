class Customer < ApplicationRecord
  has_many :carts
  has_many :addresses
  has_many :payment_methods
  has_many :orders
  validates :name, :email_address, :phone_number, :password_hash, presence: true
end
