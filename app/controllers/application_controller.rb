class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :initialize_cart

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :phone_number, :email_address ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :phone_number, :email_address ])
    devise_parameter_sanitizer.permit(:sign_in, keys: [ :login ])
  end

  private

  def initialize_cart
    @current_cart ||= Cart.find_or_create_by(id: session[:cart_id])
    session[:cart_id] ||= @current_cart.id
  end

  stale_when_importmap_changes
end
