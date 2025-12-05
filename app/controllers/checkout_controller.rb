class CheckoutController < ApplicationController
  before_action :authenticate_customer!

  include Taxable

  def cart
    redirect_to cart_path
  end

  def create_checkout_session
    cart = session[:cart] || {}
    if cart.empty?
      redirect_to cart_path, alert: "Your cart is empty!" and return
    end

    shipping_address = current_customer.addresses.find_by(is_primary: true)
    unless shipping_address
      redirect_to addresses_path, alert: "Please add a default shipping address first." and return
    end

    province_code = shipping_address.province_code

    subtotal_cents = cart.sum do |product_id, quantity|
      product = Product.find(product_id.to_i)
      (product.price * 100).to_i * quantity.to_i
    end

    tax_cents_value = tax_cents(subtotal_cents, province_code)

    puts "Province stored in DB: #{shipping_address.province.inspect}"
    puts "Province code used: #{province_code}"
    puts "Subtotal cents: #{subtotal_cents}"
    puts "Tax cents: #{tax_cents_value}"

    line_items = cart.map do |product_id, quantity|
      product = Product.find(product_id.to_i)
      {
        price_data: {
          currency: "cad",
          product_data: { name: product.name, description: product.description },
          unit_amount: (product.price * 100).to_i
        },
        quantity: quantity
      }
    end

    line_items << {
      price_data: {
        currency: "cad",
        product_data: { name: "Tax (#{province_code})" },
        unit_amount: tax_cents_value
      },
      quantity: 1
    }

    checkout_session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      success_url: "#{checkout_success_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: checkout_cancel_url,
      mode: "payment",
      line_items: line_items,
      shipping_address_collection: { allowed_countries: [ "CA" ] }
    )

    redirect_to checkout_session.url, allow_other_host: true
  end

  def success
    cart = session[:cart] || {}
    if cart.empty?
      redirect_to root_path, notice: "Your cart is empty!" and return
    end

    stripe_session = Stripe::Checkout::Session.retrieve(params[:session_id])
    payment_intent = Stripe::PaymentIntent.retrieve(stripe_session.payment_intent)

    shipping_address =
      if stripe_session.shipping.present?
        current_customer.addresses.find_by(province: stripe_session.shipping.address.state)
      else
        current_customer.addresses.find_by(is_primary: true)
      end

    province_code = shipping_address.province
    tax_rate = TAX_RATES[province_code] || 0

    charge = Stripe::Charge.retrieve(payment_intent.latest_charge)
    receipt_url = charge.receipt_url

    # wrapping the Order in a transaction in case something goes wrong.
    # ensures that either the order and its products were saved,
    # or nothing is saved if an error occurs
    ActiveRecord::Base.transaction do
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
        line_total = price_each * quantity
        tax_amount = line_total * tax_rate

        total_price += line_total + tax_amount

        order.order_products.create!(
          product: product,
          quantity: quantity,
          price_each: price_each
        )
      end

      order.update!(total_price: total_price)
    end

    session[:cart] = {}
    redirect_to orders_index_path, notice: "Thank you for your order!"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to cart_path, alert: "We couldn't process your order at this time. #{e.message}"
  end

  def cancel
  end
end
