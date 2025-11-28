class PagesController < ApplicationController
  def home
    @featured_products = Product.limit(4)
  end

  def show
    @page = Page.find_by(page_type: params[:page_type])
    if @page.nil?
      redirect_to root_path, alert: "Page not found"
    end
  end
end
