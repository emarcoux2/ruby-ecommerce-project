class CheckoutController < ApplicationController
  TAX_RATES = Rails.application.config_for(:tax_rates)

  puts "TAX_RATES = #{TAX_RATES.inspect}"

  before_action :authenticate_customer!

  def calculate_tax_cents(amount_cents, province_code)
    tax_rate = TAX_RATES[province_code] || 0
    (amount_cents * tax_rate).round
  end

  def create
    product = Product.find_by(id: params[:product_id])
    unless product
      redirect_to products_path, alert: "Product not found." and return
    end

    shipping_address = current_customer.addresses.find_by(is_primary: true)
    unless shipping_address
      redirect_to addresses_path, alert: "Please add a default shipping address first." and return
    end

    province_code = shipping_address.province
    base_price_cents = product.price_cents
    tax_cents = calculate_tax_cents(base_price_cents, province_code)

    line_items = [
      {
        price_data: {
          currency: "cad",
          product_data: {
            name: product.name,
            description: product.description
          },
          unit_amount: base_price_cents
        },
        quantity: 1
      },
      {
        price_data: {
          currency: "cad",
          product_data: {
            name: "Tax (#{province_code})"
          },
          unit_amount: tax_cents
        },
        quantity: 1
      }
    ]

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      success_url: "#{checkout_success_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: checkout_cancel_url,
      mode: "payment",
      line_items: line_items,
      shipping_address_collection: {
        allowed_countries: [ "CA" ]
      }
    )

    redirect_to session.url, allow_other_host: true
  end

  def cart
    if session[:cart].blank? || session[:cart].empty?
      redirect_to root_path, notice: "Fill your cart with products to buy!" and return
    end

    shipping_address = current_customer.addresses.find_by(is_primary: true)
    unless shipping_address
      redirect_to addresses_path, alert: "Please add a default shipping address first." and return
    end
    province_code = shipping_address.province

    products = Product.find(session[:cart].keys)

    line_items = products.map do |product|
      quantity = session[:cart][product.id.to_s].to_i
      base_price_cents = (product.price * 100).to_i
      tax_cents = calculate_tax_cents(base_price_cents * quantity, province_code)

      [
        {
          price_data: {
            currency: "cad",
            product_data: { name: product.name, description: product.description.presence },
            unit_amount: base_price_cents
          },
          quantity: quantity
        },
        {
          price_data: {
            currency: "cad",
            product_data: { name: "Tax (#{province_code}) for #{product.name}" },
            unit_amount: tax_cents
          },
          quantity: 1
        }
      ]
    end.flatten

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

    province_code = if stripe_session.shipping.present?
                      stripe_session.shipping.address.state
    else
                      current_customer.addresses.first&.province || "ON"
    end
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
