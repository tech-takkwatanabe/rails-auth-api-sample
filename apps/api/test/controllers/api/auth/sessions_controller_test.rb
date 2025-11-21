require "test_helper"

module Api
  module Auth
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = User.create!(name: "test", email: "test-session@example.com", password: "password", password_confirmation: "password")
      end

      test "should get token with valid credentials" do
        post api_auth_login_url, params: { email: @user.email, password: "password" }, as: :json
        assert_response :ok
        
        json_response = JSON.parse(response.body)
        assert_not_nil json_response["access_token"]
        assert_not_nil json_response["refresh_token"]
      end

      test "should not get token with invalid password" do
        post api_auth_login_url, params: { email: @user.email, password: "wrong_password" }, as: :json
        assert_response :unauthorized
      end

      test "should not get token for non-existent user" do
        post api_auth_login_url, params: { email: "nonexistent@example.com", password: "password" }, as: :json
        assert_response :unauthorized
      end

      test "should logout and invalidate refresh token" do
        # 1. Login to get tokens
        post api_auth_login_url, params: { email: @user.email, password: "password" }, as: :json
        assert_response :ok
        json_response = JSON.parse(response.body)
        access_token = json_response["access_token"]
        refresh_token = json_response["refresh_token"]

        # 2. Logout
        headers = { 'Authorization' => "Bearer #{access_token}" }
        post api_auth_logout_url, params: { refresh_token: refresh_token }, headers: headers, as: :json
        assert_response :no_content

        # 3. Verify refresh token is invalidated
        assert_nil $redis.get("refresh_token:#{refresh_token}")
      end
    end
  end
end
