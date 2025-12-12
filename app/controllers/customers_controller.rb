class CustomersController < ApplicationController
  def index
  end

  def show
    @customer = current_customer
    # Fetch the primary address
    @primary_address = @customer.addresses.find_by(is_primary: true)
    # Fetch most recent order (optional)
    @recent_order = @customer.orders.order(order_date: :desc).first
  end
end
