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
    products = Product.find(session[:cart].keys)

    if products.nil? or products.empty?
      flash[:notice] = "Fill your cart with products to buy!"
      redirect_to root_path

      session = Stripe::Checkout::Session.create(
        payment_method_types: [ "card" ],
        success_url: checkout_success_url,
        cancel_url: checkout_cancel_url,
        mode: "payment",
        line_items: products.map do |product|
          {
            price_data: {
              currency: "cad",
              product_data: {
                name: product.name,
                description: product.description
              },
              unit_amount: product.price_cents
            },
            quantity: session[:cart][product.id.to_s]["quantity"]
          }
        end
      )
      redirect_to session.url, allow_other_host: true
    end
  end

  def cancel
  end

  def success
    session[:cart] = {}
  end
end
