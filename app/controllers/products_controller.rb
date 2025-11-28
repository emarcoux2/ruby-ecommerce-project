class ProductsController < ApplicationController
  def index
    @products = Product.where(is_active: true).includes(:category)

    if params[:category].present?
      @selected_category = Category.find_by(id: params[:category])
      @products = @products.where(category_id: @selected_category.id) if @selected_category
    end

    if params[:query].present?
      @products = @products.where("name LIKE ?", "%#{params[:query].downcase}%")
    end

    @products = @products.order(:name).page(params[:page]).per(32)

    @categories = Category.order(:name)
  end

  def show
    @product = Product.find(params[:id])
  end
end
