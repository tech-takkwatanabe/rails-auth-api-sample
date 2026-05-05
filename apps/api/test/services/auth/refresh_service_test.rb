require "test_helper"

class Auth::RefreshServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "test", email: "refresh-test@example.com", password: "password")
    @tokens = Auth::TokenService.issue_tokens(@user)
  end

  test "call returns new token pair with valid refresh token" do
    result = Auth::RefreshService.call(refresh_token: @tokens[:refresh_token])

    assert result[:success]
    assert_not_nil result[:payload][:access_token]
    assert_not_nil result[:payload][:refresh_token]
    assert_not_equal @tokens[:refresh_token], result[:payload][:refresh_token]
  end

  test "call revokes old refresh token" do
    old_token = @tokens[:refresh_token]
    Auth::RefreshService.call(refresh_token: old_token)

    assert_nil $redis.get("refresh_token:#{old_token}")
  end

  test "call stores new refresh token in Redis" do
    result = Auth::RefreshService.call(refresh_token: @tokens[:refresh_token])
    new_token = result[:payload][:refresh_token]

    assert_not_nil $redis.get("refresh_token:#{new_token}")
  end

  test "call fails with invalid refresh token" do
    result = Auth::RefreshService.call(refresh_token: "invalid_token")

    assert_not result[:success]
    assert_equal "Invalid refresh token", result[:error]
  end

  test "call fails with already used refresh token" do
    Auth::RefreshService.call(refresh_token: @tokens[:refresh_token])
    result = Auth::RefreshService.call(refresh_token: @tokens[:refresh_token])

    assert_not result[:success]
    assert_equal "Invalid refresh token", result[:error]
  end
end
