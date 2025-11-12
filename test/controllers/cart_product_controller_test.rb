require "test_helper"

class CartProductControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get cart_product_index_url
    assert_response :success
  end

  test "should get show" do
    get cart_product_show_url
    assert_response :success
  end
end
