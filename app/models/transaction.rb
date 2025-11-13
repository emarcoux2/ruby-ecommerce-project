class Transaction < ApplicationRecord
  belongs_to :order
  validates :currency, :amount, :status, :provider, presence: true
end
