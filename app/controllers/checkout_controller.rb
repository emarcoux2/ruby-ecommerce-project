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

    line_items = cart.map do |product_id, quantity|
      product = Product.find(product_id.to_i)
      {
        price_data: {
          currency: "cad",
          product_data: {
            name: product.name
          }.tap do |pd|
            pd[:description] = product.description if product.description.present?
          end,
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

  # Determine province from Stripe shipping OR fallback to customer's primary address
  if stripe_session.respond_to?(:shipping) && stripe_session.shipping
    province_code = stripe_session.shipping.address.state
    shipping_address = current_customer.addresses.find_by(province: province_code)
  else
    shipping_address = current_customer.addresses.find_by(is_primary: true)
    province_code = shipping_address.province
  end

  tax_rate = TAX_RATES[province_code] || 0

  charge = Stripe::Charge.retrieve(payment_intent.latest_charge)
  receipt_url = charge.receipt_url

  ActiveRecord::Base.transaction do
    order = current_customer.orders.create!(
      total_price: 0,
      tax_cents: 0,
      status: "paid",
      receipt_url: receipt_url,
      order_date: Time.current
    )

    subtotal_cents = 0
    total_tax_cents = 0

    cart.each do |product_id_str, quantity|
      product = Product.find(product_id_str.to_i)
      quantity = quantity.to_i

      price_each_cents = (product.price * 100).to_i
      line_total_cents = price_each_cents * quantity
      line_tax_cents = (line_total_cents * tax_rate).round

      subtotal_cents += line_total_cents
      total_tax_cents += line_tax_cents

      order.order_products.create!(
        product: product,
        quantity: quantity,
        price_each: price_each_cents
      )
    end

    order.update!(
      total_price: subtotal_cents + total_tax_cents,
      tax_cents: total_tax_cents
    )
  end

  session[:cart] = {}
  redirect_to orders_path, notice: "Thank you for your order!"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to cart_path, alert: "We couldn't process your order at this time. #{e.message}"
  end


  def cancel
  end
end
