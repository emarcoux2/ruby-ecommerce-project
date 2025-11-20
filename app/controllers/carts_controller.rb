class CartsController < ApplicationController
  def add
    session[:cart] << params[:product_id]
    flash[:notice] = "Item added to cart!"
  end

  def quantity
    product_id = params[:product_id]
    quantity = params[:quantity].to_i

    if session[:cart][product_id].nil?
      flash[:notice] = "Product not found in cart."
    end

    if quantity <= 0
      flash[:notice] = "Invalid quantity."
    end

    session[:cart][product_id]["quantity"] = quantity
  end

  def destroy
    session[:cart] = {}
    flash[:notice] = "Nothing in your cart! Start shopping!"
  end
end
