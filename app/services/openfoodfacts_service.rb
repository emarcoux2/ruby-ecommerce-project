# encoding: utf-8

require "net/http"
require "open-uri"
require "json"
require "cgi"
require "fileutils"

class OpenFoodFactsService
  BASE_URL = "https://world.openfoodfacts.org"

  CACHE_DIR = Rails.root.join("tmp", "open_food_facts_cache")
  FileUtils.mkdir_p(CACHE_DIR) unless Dir.exist?(CACHE_DIR)

  def self.search_products(term, limit: 50)
    cache_file = CACHE_DIR.join("#{term.parameterize}.json")

    if File.exist?(cache_file)
      data = JSON.parse(File.read(cache_file))
    else
      url = "#{BASE_URL}/cgi/search.pl?#{URI.encode_www_form({
      search_terms: term,
      search_simple: 1,
      action: "process",
      json: 1,
      page_size: limit,
      lc: "en",
      lang: "en"
    })}"

      response = URI.open(url).read
      data = JSON.parse(response)
      File.write(cache_file, JSON.pretty_generate(data))
    end
    data["products"] || []

  rescue => e
    Rails.logger.error "OFF API Error: #{e.message}"
    []
  end

  def self.fetch_product(barcode)
    cache_file = CACHE_DIR.join("product_#{barcode}.json")

    if File.exist?(cache_file)
      data = JSON.parse(File.read(cache_file))
    else
      url = "#{BASE_URL}/api/v0/product/#{barcode}.json"
      response = URI.open(url).read
      data = JSON.parse(response)
      File.write(cache_file, JSON.pretty_generate(data))
    end
    data["product"]

  rescue => e
    Rails.logger.error "OFF Product Fetch Error: #{e.message}"
    nil
  end
end
