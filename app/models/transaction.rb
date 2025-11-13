class Transaction < ApplicationRecord
  belongs_to :order

  validates :currency, :amount, :status, :provider, presence: true
  validates :currency, numericality: { only_integer: true }
  validates :amount, numericality: true
end
