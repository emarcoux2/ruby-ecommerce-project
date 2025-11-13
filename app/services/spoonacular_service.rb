require "net/http"
require "uri"
require "json"

class SpoonacularService
  BASE_URL = "https://api.spoonacular.com"

  def initialize
    @api_key = ENV["SPOONACULAR_API_KEY"]
  end

  def fetch_products_page(number: 100, offset: 0)
    url = URI("#{BASE_URL}/food/products/search?number=#{number}&offset=#{offset}&apiKey=#{@api_key}")
    response = Net::HTTP.get(url)
    JSON.parse(response)
  end

  def fetch_product_details
    url = URI("#{BASE_URL}/food/products/#{product_id}?apiKey=#{@api_key}")
    response = Net::HTTP.get(url)
    JSON.parse(response)
  end
end
