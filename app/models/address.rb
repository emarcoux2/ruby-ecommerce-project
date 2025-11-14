class Address < ApplicationRecord
  belongs_to :customer

  validates :street, :city, :postal_code, :province, presence: true
  validates :is_primary, inclusion: { in: [ true, false ] }
end
