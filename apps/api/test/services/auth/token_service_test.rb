require "test_helper"

class Auth::TokenServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "test", email: "token-test@example.com", password: "password")
  end

  test "issue_tokens returns access_token and refresh_token" do
    tokens = Auth::TokenService.issue_tokens(@user)

    assert_not_nil tokens[:access_token]
    assert_not_nil tokens[:refresh_token]
  end

  test "issue_tokens stores refresh_token in Redis" do
    tokens = Auth::TokenService.issue_tokens(@user)
    stored_user_id = $redis.get("refresh_token:#{tokens[:refresh_token]}")

    assert_equal @user.id.to_s, stored_user_id
  end

  test "revoke_refresh_token removes token from Redis" do
    tokens = Auth::TokenService.issue_tokens(@user)
    Auth::TokenService.revoke_refresh_token(tokens[:refresh_token])

    assert_nil $redis.get("refresh_token:#{tokens[:refresh_token]}")
  end

  test "find_user_by_refresh_token returns user for valid token" do
    tokens = Auth::TokenService.issue_tokens(@user)
    found_user = Auth::TokenService.find_user_by_refresh_token(tokens[:refresh_token])

    assert_equal @user, found_user
  end

  test "find_user_by_refresh_token returns nil for invalid token" do
    found_user = Auth::TokenService.find_user_by_refresh_token("invalid_token")

    assert_nil found_user
  end
end
