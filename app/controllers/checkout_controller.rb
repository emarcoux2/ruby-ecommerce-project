class CheckoutController < ApplicationController
  def create
    product = Product.find(params[:product_id])

    if product.nil?
      redirect_to products_path
    end

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      success_url: "#{checkout_success_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: checkout_cancel_url,
      mode: "payment",
      line_items: [
        {
          price_data: {
            currency: "cad",
            product_data: {
              name: product.name,
              description: product.description
            },
            unit_amount: product.price_cents
          },
          quantity: 1
        }
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
      success_url: "#{checkout_success_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: checkout_cancel_url,
      mode: "payment",
      line_items: line_items
    )

    redirect_to checkout_session.url, allow_other_host: true
  end

  def success
    cart = session[:cart] || {}

    if cart.empty?
      redirect_to root_path, notice: "Your cart is empty!" and return
    end

    # wrapping the Order in a transaction in case something goes wrong.
    # ensures that either the order and its products were saved,
    # or nothing is saved if an error occurs
    ActiveRecord::Base.transaction do
      stripe_session = Stripe::Checkout::Session.retrieve(params[:session_id])
      payment_intent = Stripe::PaymentIntent.retrieve(stripe_session.payment_intent)
      charge = Stripe::Charge.retrieve(payment_intent.latest_charge)
      receipt_url = charge.receipt_url

      order = current_customer.orders.create!(
        total_price: 0,
        status: "paid",
        receipt_url: receipt_url,
        order_date: Time.current
      )

      total_price = 0

      cart.each do |product_id_str, quantity|
        product = Product.find(product_id_str.to_i)
        quantity = quantity.to_i
        price_each = product.price

        total_price += price_each * quantity

        order.order_products.create!(
          product: product,
          quantity: quantity,
          price_each: price_each
        )
      end

      order.update!(total_price: total_price)
    end

    session[:cart] = {}

    flash[:notice] = "Thank you for your order!"
    redirect_to orders_index_path
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "We couldn't process your order at this time. #{e.message}"
    redirect_to cart_path
  end

  def cancel
  end
end
