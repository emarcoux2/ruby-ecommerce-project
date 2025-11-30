class Product < ApplicationRecord
  belongs_to :category

  has_many :cart_products
  has_many :carts, through: :cart_products

  has_many :order_products
  has_many :orders, through: :order_products

  validates :name, :quantity, :unit, :price, :is_active, presence: true
  validates :quantity, numericality: { only_integer: true }
  validates :price, numericality: true
  validates :name, uniqueness: true

  has_one_attached :image

  def self.ransackable_attributes(auth_object = nil)
    [ "category_id", "created_at", "description", "id", "id_value", "image_url", "is_active", "name", "price", "quantity", "sku", "unit", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "cart_products", "carts", "category" ]
  end
end
