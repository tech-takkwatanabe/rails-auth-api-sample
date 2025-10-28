require "test_helper"

module Api
  module Auth
    class UsersControllerTest < ActionDispatch::IntegrationTest
      test "should create user with valid data" do
        user_params = { user: { name: "testuser", email: "test@example.com", password: "password", password_confirmation: "password" } }
        
        assert_difference('User.count', 1) do
          post api_auth_signup_url, params: user_params, as: :json
        end

        assert_response :created
        
        json_response = JSON.parse(response.body)
        assert_not_nil json_response["uuid"]
        assert_equal "testuser", json_response["name"]
        assert_equal "test@example.com", json_response["email"]
      end

      test "should not create user with invalid data" do
        user_params = { user: { name: "testuser", email: "test@example.com", password: "password", password_confirmation: "wrong_password" } }

        assert_no_difference('User.count') do
          post api_auth_signup_url, params: user_params, as: :json
        end

        assert_response :unprocessable_entity
      end
    end
  end
end
