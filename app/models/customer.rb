class Customer < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_validation :sync_email_and_email_address

  has_many :carts
  has_many :addresses
  has_many :payment_methods
  has_many :orders

  validates :name, :email_address, :phone_number, presence: true

  private

  def sync_email_and_email_address
    self.email = email_address if email_address.present?
  end
end
