class CartsController < ApplicationController
  before_action :initialize_cart

  include Taxable

  def add
    product_id = params[:product_id].to_s
    quantity = (params[:quantity] || 1).to_i

    session[:cart][product_id] ||= 0
    session[:cart][product_id] += quantity

    flash[:notice] = "#{Product.find(product_id).name} added to cart."
    redirect_back fallback_location: products_path
  end

  def update
    product_id = params[:product_id].to_s
    quantity = params[:quantity].to_i

    if quantity > 0
      @cart[product_id] = quantity
    else
      @cart.delete(product_id)
    end

    session[:cart] = @cart
    redirect_to cart_path, notice: "Cart has been updated."
  end

  def destroy
    # remove a single item from the cart
    if params[:product_id].present?
      @cart.delete(params[:product_id].to_s)
      notice = "Product removed from cart!"

    # remove all items from the cart
    else
      @cart.clear
      notice = "All items have been removed from your cart!"
    end

    session[:cart] = @cart
    redirect_to cart_path, notice: notice
  end

  def show
    @cart_products = Product.where(id: @cart.keys)

    @primary_address = current_customer.addresses.find_by(is_primary: true)

    @subtotal_cents = @cart_products.sum do |product|
      qty = @cart[product.id.to_s].to_i
      (product.price * 100).to_i * qty
    end

    @subtotal_cents ||= 0

    shipping_address = current_customer.addresses.find_by(is_primary: true)
    province_code = shipping_address.province_code
    @tax_cents = tax_cents(@subtotal_cents, province_code)

    @total_cents = @subtotal_cents + @tax_cents
  end

  private

  def initialize_cart
    session[:cart] ||= {}
    @cart = session[:cart]
    @cart_count = @cart.values.sum
  end
end
