require "test_helper"

class Auth::LogoutServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "test", email: "logout-test@example.com", password: "password")
    @tokens = Auth::TokenService.issue_tokens(@user)
  end

  test "call revokes the refresh token" do
    Auth::LogoutService.call(refresh_token: @tokens[:refresh_token])

    assert_nil $redis.get("refresh_token:#{@tokens[:refresh_token]}")
  end
end
