class Address < ApplicationRecord
  belongs_to :customer

  validates :street, :city, :postal_code, :province, :is_primary, presence: true
end
