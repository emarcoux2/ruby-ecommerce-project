class Customer < ApplicationRecord
  has_many :carts, :addresses, :payment_methods, :orders

  validates :name, :email_address, :phone_number, :password_hash, presence: true, uniqueness: true
  validates :phone_number, numericality: true
end
