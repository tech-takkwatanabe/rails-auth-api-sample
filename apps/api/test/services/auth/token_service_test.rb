require "test_helper"

class Auth::TokenServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "test", email: "token-test@example.com", password: "password")
    @issued_tokens = []
  end

  teardown do
    @issued_tokens.each do |t|
      $redis.del("#{Auth::TokenService::REFRESH_TOKEN_PREFIX}#{t[:refresh_token]}")
    end
  end

  test "issue_tokens returns access_token and refresh_token" do
    tokens = Auth::TokenService.issue_tokens(@user).tap { |t| @issued_tokens << t }

    assert_not_nil tokens[:access_token]
    assert_not_nil tokens[:refresh_token]
  end

  test "issue_tokens stores refresh_token in Redis" do
    tokens = Auth::TokenService.issue_tokens(@user).tap { |t| @issued_tokens << t }
    stored_user_id = $redis.get("#{Auth::TokenService::REFRESH_TOKEN_PREFIX}#{tokens[:refresh_token]}")

    assert_equal @user.id.to_s, stored_user_id
  end

  test "revoke_refresh_token removes token from Redis" do
    tokens = Auth::TokenService.issue_tokens(@user).tap { |t| @issued_tokens << t }
    Auth::TokenService.revoke_refresh_token(tokens[:refresh_token])

    assert_nil $redis.get("#{Auth::TokenService::REFRESH_TOKEN_PREFIX}#{tokens[:refresh_token]}")
  end

  test "consume_refresh_token returns user and removes token for valid token" do
    tokens = Auth::TokenService.issue_tokens(@user).tap { |t| @issued_tokens << t }
    found_user = Auth::TokenService.consume_refresh_token(tokens[:refresh_token])

    assert_equal @user, found_user
    assert_nil $redis.get("#{Auth::TokenService::REFRESH_TOKEN_PREFIX}#{tokens[:refresh_token]}")
  end

  test "consume_refresh_token returns nil for invalid token" do
    found_user = Auth::TokenService.consume_refresh_token("invalid_token")

    assert_nil found_user
  end
end
