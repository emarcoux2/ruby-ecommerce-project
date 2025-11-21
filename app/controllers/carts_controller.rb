class CartsController < ApplicationController
  before_action :initialize_cart

  def add
    product_id = params[:product_id].to_s
    quantity = (params[:quantity] || 1).to_i

    product = Product.find(product_id)

    session[:cart] ||= {}

    session[:cart][product_id] ||= 0
    session[:cart][product_id] += quantity

    flash[:notice] = "#{product.name} was added to your cart."
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
    product_id = params[:product_id].to_s

    @cart.delete(product_id)
    session[:cart] = @cart

    redirect_to cart_path, notice: "Product removed from cart!"
  end

  def show
    @cart_products = Product.where(id: @cart.keys)
  end

  private

  def initialize_cart
    session[:cart] ||= {}
    @cart = session[:cart]
    @cart_count = @cart.values.sum
  end
end
