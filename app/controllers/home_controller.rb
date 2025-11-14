class HomeController < ApplicationController
  def index
    @products = Product.where(is_active: true).includes(:category)
    @products = Product.page(params[:page]).per(32)

    @categories = Category.order(:name)

    if params[:category].present?
      @selected_category = Category.find_by(id: params[:category])
      @products = Product.where(category_id: @selected_category.id).page(params[:page])
    else
      @products = Product.page(params[:page])
    end
  end
end
