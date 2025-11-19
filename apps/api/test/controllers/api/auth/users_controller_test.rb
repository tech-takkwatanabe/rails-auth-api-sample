require "test_helper"

module Api
  module Auth
    class UsersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = User.create!(name: "testuser", email: "test@example.com", password: "password")
      end

      # --- Signup Tests ---
      test "should create user with valid data" do
        user_params = { user: { name: "newuser", email: "new@example.com", password: "password", password_confirmation: "password" } }
        
        assert_difference('User.count', 1) do
          post api_auth_signup_url, params: user_params, as: :json
        end

        assert_response :created
        
        json_response = JSON.parse(response.body)
        assert_not_nil json_response["uuid"]
        assert_equal "newuser", json_response["name"]
        assert_equal "new@example.com", json_response["email"]
      end

      test "should not create user with invalid data" do
        user_params = { user: { name: "testuser", email: "test@example.com", password: "password", password_confirmation: "wrong_password" } }

        assert_no_difference('User.count') do
          post api_auth_signup_url, params: user_params, as: :json
        end

        assert_response :unprocessable_entity
      end

      # --- ME Endpoint Tests ---
      test "should get user info with valid token" do
        token = JsonWebToken.encode(user_id: @user.id)
        headers = { 'Authorization' => "Bearer #{token}" }
        get api_auth_me_url, headers: headers, as: :json

        assert_response :ok
        json_response = JSON.parse(response.body)
        assert_equal @user.uuid, json_response["uuid"]
        assert_equal @user.name, json_response["name"]
        assert_equal @user.email, json_response["email"]
      end

      test "should not get user info without token" do
        get api_auth_me_url, as: :json
        assert_response :unauthorized
      end

      test "should not get user info with invalid token" do
        headers = { 'Authorization' => "Bearer invalidtoken" }
        get api_auth_me_url, headers: headers, as: :json
        assert_response :unauthorized
      end
    end
  end
end
