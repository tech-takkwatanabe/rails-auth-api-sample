require "test_helper"

class Auth::LogoutServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "test", email: "logout-test@example.com", password: "password")
    @tokens = Auth::TokenService.issue_tokens(@user)
  end

  teardown do
    $redis.del("#{Auth::TokenService::REFRESH_TOKEN_PREFIX}#{@tokens[:refresh_token]}")
  end

  test "call revokes the refresh token" do
    Auth::LogoutService.call(refresh_token: @tokens[:refresh_token])

    assert_nil $redis.get("#{Auth::TokenService::REFRESH_TOKEN_PREFIX}#{@tokens[:refresh_token]}")
  end

  test "call is idempotent given an invalid or already-revoked refresh token" do
    Auth::LogoutService.call(refresh_token: @tokens[:refresh_token])
    assert_nothing_raised do
      Auth::LogoutService.call(refresh_token: @tokens[:refresh_token])
    end

    assert_nothing_raised do
      Auth::LogoutService.call(refresh_token: "invalid_token")
    end
  end
end
