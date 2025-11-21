class Customer < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :carts
  has_many :addresses
  has_many :payment_methods
  has_many :orders

  validates :name, :email_address, :phone_number, :password_hash, presence: true

  attr_writer :login
  def login
    @login || self.email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup

    if login = conditions.delete(:login)
      where(conditions).where(
        [ "lower(email) = :value", { value: login.downcase } ]
      ).first
    else
      where(conditions).first
    end
  end
end
