class AddressesController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_address, only: [ :edit, :update, :destroy ]

  def index
    @addresses = current_customer.addresses.order(created_at: :desc)

    if @addresses.empty?
      redirect_to new_address_path, notice: "Please add an address first."
    end
  end

  def show
  end

  def new
    @address = current_customer.addresses.new
  end

  def create
    @address = current_customer.addresses.new(address_params)
    @address.is_primary = true if current_customer.addresses.empty?

    if @address.save
      redirect_to addresses_path, notice: "Address added successfully."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if address_params[:is_primary] == "1"
      current_customer.addresses.update_all(is_primary: false)
    end

    if @address.update(address_params)
      redirect_to addresses_path, notice: "Address updated successfully."
    else
      flash.now[:alert] = @address.errors.full_messages.join(", ")
      render :edit
    end
  end

  def destroy
    @address.destroy
    redirect_to addresses_path, notice: "Address deleted successfully."
  end

  private

  def set_address
    @address = current_customer.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(
      :street,
      :city,
      :province,
      :postal_code,
      :is_primary
    )
  end
end
