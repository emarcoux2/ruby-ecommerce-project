class CustomersController < ApplicationController
  def index
  end

  def show
    @customer = current_customer
    @primary_address = @customer.addresses.find_by(is_primary: true)
    @recent_order = @customer.orders.order(order_date: :desc).first
  end
end
