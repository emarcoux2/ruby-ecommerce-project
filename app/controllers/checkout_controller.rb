class CheckoutController < ApplicationController
  def create
    product = Product.find(params[:product_id])

    if product.nil?
      redirect_to products_path
    end

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      success_url: checkout_success_url,
      cancel_url: checkout_cancel_url,
      mode: "payment",
      line_items: [
        price_data: {
          currency: "cad",
          product_data: {
            name: product.name,
            description: product.description
          },
          unit_amount: product.price_cents
        },
        quantity: 1
      ]
    )

    redirect_to session.url, allow_other_host: true
  end

  def cart
    if session[:cart].blank? || session[:cart].empty?
      flash[:notice] = "Fill your cart with products to buy!"
      redirect_to root_path and return
    end

    products = Product.find(session[:cart].keys)

    line_items = products.map do |product|
      quantity = session[:cart][product.id.to_s] || 1

      product_data = { name: product.name }

      if product.description.present? && product.description.strip != ""
        product_data[:description] = product.description
      end

      {
        price_data: {
          currency: "cad",
          product_data: product_data,
          unit_amount: (product.price * 100).to_i
        },
        quantity: quantity
      }
    end

    checkout_session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      success_url: checkout_success_url,
      cancel_url: checkout_cancel_url,
      mode: "payment",
      line_items: line_items
    )

    redirect_to checkout_session.url, allow_other_host: true
  end

  def cancel
  end

  def success
    session[:cart] = {}
  end
end
