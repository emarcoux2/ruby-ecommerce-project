class OrdersController < ApplicationController
  before_action :set_order, only: [ :show ]
  def index
    @orders = current_customer.orders.order(order_date: :desc)
  end

  def show
    if params[:id].blank?
      redirect_to orders_path, alert: "No order specified." and return
    end

    @order = Order.find(params[:id])
    @order_products = @order.order_products.includes(:product)
  end

  private

  def set_order
    @order = current_customer.orders.find(params[:id])
  end
end
