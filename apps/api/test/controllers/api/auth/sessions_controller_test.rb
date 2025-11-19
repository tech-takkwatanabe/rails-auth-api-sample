require "test_helper"

module Api
  module Auth
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = User.create!(name: "test", email: "test@example.com", password: "password", password_confirmation: "password")
      end

      test "should get token with valid credentials" do
        post api_auth_login_url, params: { email: "test@example.com", password: "password" }, as: :json
        assert_response :ok
        
        json_response = JSON.parse(response.body)
        assert_not_nil json_response["access_token"]
        assert_not_nil json_response["refresh_token"]
      end

      test "should not get token with invalid password" do
        post api_auth_login_url, params: { email: "test@example.com", password: "wrong_password" }, as: :json
        assert_response :unauthorized
      end

      test "should not get token for non-existent user" do
        post api_auth_login_url, params: { email: "nonexistent@example.com", password: "password" }, as: :json
        assert_response :unauthorized
      end
    end
  end
end
