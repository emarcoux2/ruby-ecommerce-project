
require "faker"
require "securerandom"
require "fileutils"
require "set"

MAX_PRODUCTS = 4000
total_count = 0

CartProduct.destroy_all
OrderProduct.destroy_all
Transaction.destroy_all
Order.destroy_all
Cart.destroy_all
Product.destroy_all
Address.destroy_all
PaymentMethod.destroy_all
Customer.destroy_all
Category.destroy_all

puts "Seeding customers..."

CUSTOMER_COUNT = 500
customers = []

CUSTOMER_COUNT.times do
  customers << Customer.create!(
    name:          Faker::Name.name,
    email_address: Faker::Internet.unique.email,
    phone_number:  Faker::PhoneNumber.phone_number,
    password_hash: Faker::Internet.password(
      min_length: 8,
      max_length: 20,
      mix_case: true,
      special_characters: true
    )
  )
end

puts "Seeding addresses..."

PROVINCES = %w[
  AB BC MB NB NL NS NT NU ON PE QC SK YT
]

customers.each do |customer|
  address_count = rand(1..3)

  created_addresses = address_count.times.map do
    Address.create!(
      customer:    customer,
      street:      Faker::Address.street_address,
      city:        Faker::Address.city,
      postal_code: Faker::Address.postcode,
      province:    PROVINCES.sample,
      is_primary:  false
    )
  end

  # updating one of a customer's addresses to true
  # to set it as the primary address
  primary = created_addresses.sample
  primary.update!(is_primary: true)

  puts "Customer #{customer.name} has #{address_count} addresses (#{primary.id} is primary)"
end

puts "Created #{customers.size} customers"

puts "Seeding categories..."
CATEGORIES = %w[
  Produce
  Bakery
  Dairy
  Meat
  Frozen
  Pantry
  Beverages
  Snacks
  Household
]

categories = {}
CATEGORIES.each do |name|
  categories[name] = Category.create!(name: name)
end
puts "Categories seeded!"

SEARCH_TERMS = {
  "Produce"   => [ "apple", "banana", "carrot", "lettuce", "tomato", "cucumber", "strawberry", "grapes", "onion", "pepper" ],
  "Bakery"    => [ "bread", "croissant", "bagel", "muffin", "brioche", "baguette", "donut", "cake", "rolls", "pretzel" ],
  "Dairy"     => [ "milk", "cheese", "yogurt", "butter", "cream", "cottage cheese", "ice cream", "cheddar", "feta", "kefir" ],
  "Meat"      => [ "chicken", "beef", "ham", "pork", "bacon", "sausage", "turkey", "salami", "ground beef", "lamb" ],
  "Frozen"    => [ "frozen pizza", "ice cream", "frozen veggies", "frozen berries", "frozen meals", "frozen fish", "frozen fries", "frozen desserts", "frozen dumplings", "frozen nuggets" ],
  "Pantry"    => [ "pasta", "rice", "beans", "canned tuna", "lentils", "cereal", "oats", "flour", "sugar", "canned tomatoes" ],
  "Beverages" => [ "juice", "soda", "coffee", "tea", "energy drink", "sparkling water", "milkshake", "smoothie", "beer", "wine" ],
  "Snacks"    => [ "chips", "chocolate", "cookies", "nuts", "granola bar", "popcorn", "pretzels", "candy", "crackers", "trail mix" ],
  "Household" => [ "dish soap", "laundry detergent", "paper towels", "toilet paper", "cleaning wipes", "sponges", "trash bags", "bleach", "fabric softener", "all-purpose cleaner" ]
}

# saves JSON responses to prevent repeated API calls during seeding
CACHE_DIR = Rails.root.join("tmp", "open_food_facts_cache")
FileUtils.mkdir_p(CACHE_DIR) unless Dir.exist?(CACHE_DIR)

# helper method to fetch products with caching and error handling
def fetch_openfoodfacts_products(term, limit: 50)
  cache_file = CACHE_DIR.join("#{term.parameterize}.json")
  return JSON.parse(File.read(cache_file))["products"] if File.exist?(cache_file)

  params = {
    search_terms: term,
    search_simple: 1,
    action: "process",
    json: 1,
    page_size: limit,
    lc: "en",
    lang: "en"
  }

  url = "https://world.openfoodfacts.org/cgi/search.pl?#{URI.encode_www_form(params)}"

  begin
    response = URI.open(url, read_timeout: 5).read
    data = JSON.parse(response)
    File.write(cache_file, JSON.pretty_generate(data))
    data["products"] || []
  rescue => e
    puts "Error fetching '#{term}': #{e.message}"
    []
  end
end

puts "Seeding products (up to #{MAX_PRODUCTS})..."

existing_names = Product.pluck(:name).to_set

CATEGORIES.each do |category_name|
  category = categories[category_name]
  added_count = 0

  SEARCH_TERMS[category_name].each do |term|
    break if total_count >= MAX_PRODUCTS
    products = fetch_openfoodfacts_products(term, limit: 50)
    next if products.blank?

    products.each do |p|
      break if total_count >= MAX_PRODUCTS
      next if p["product_name"].nil? || p["product_name"].strip.empty?
      next if existing_names.include?(p["product_name"])

      is_active_value = [ true, true, true, false ].sample || true
      unit_value      = p["quantity"].to_s.strip.presence || "1 item"

      image_url =
        p["image_front_url"] ||
        p["image_url"] ||
        p["image_small_url"] ||
        p["image_thumb_url"] ||
        nil

      next if image_url.nil?

      begin
        product = Product.create!(
          name:        p["product_name"],
          description: p["generic_name"] || p["ingredients_text"] || "No description available.",
          quantity:    rand(1..100),
          category_id: category.id,
          unit:        unit_value,
          price:       Faker::Commerce.price(range: 1.0..20.0, as_string: false),
          sku:         p["code"] || SecureRandom.hex(6),
          is_active:   is_active_value,
          image_url:   image_url
        )

        total_count += 1
        added_count += 1
        existing_names.add(p["product_name"])
        puts "✅ Created: #{product.name} ($#{product.price}) in #{category.name}"
      rescue ActiveRecord::RecordInvalid => e
        puts "⚠ Skipped '#{p['product_name']}' due to validation error: #{e.message}"
      end
    end
  end

  puts "Finished #{category_name}: #{added_count} products added"
  break if total_count >= MAX_PRODUCTS
end

# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
