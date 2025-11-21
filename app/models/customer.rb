class Customer < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :carts
  has_many :addresses
  has_many :payment_methods
  has_many :orders

  validates :name, :email_address, :phone_number, presence: true

  def email
    self.email_address
  end

  def email=(value)
    self.email_address = value
  end
end
