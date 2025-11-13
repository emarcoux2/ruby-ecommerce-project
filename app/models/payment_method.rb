class PaymentMethod < ApplicationRecord
  belongs_to :customer
  validates :provider, presence: true
end
