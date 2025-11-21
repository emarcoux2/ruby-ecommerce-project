class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :initialize_cart

  private

  def initialize_cart
    @current_cart ||= Cart.find_or_create_by(id: session[:cart_id])
    session[:cart_id] ||= @current_cart.id
  end

  stale_when_importmap_changes
end
