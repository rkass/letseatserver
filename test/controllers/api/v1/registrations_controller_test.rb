require 'test_helper'

class Api::V1::RegistrationsControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

end
