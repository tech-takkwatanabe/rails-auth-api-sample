require "test_helper"

class Auth::LoginServiceTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(name: "test", email: "login-test@example.com", password: "password")
  end

  test "call returns tokens with valid credentials" do
    result = Auth::LoginService.call(email: @user.email, password: "password")

    assert result[:success]
    assert_not_nil result[:payload][:access_token]
    assert_not_nil result[:payload][:refresh_token]
    assert_equal @user.uuid, result[:payload][:uuid]
  end

  test "call fails with wrong password" do
    result = Auth::LoginService.call(email: @user.email, password: "wrong_password")

    assert_not result[:success]
    assert_equal "Invalid email or password", result[:error]
  end

  test "call fails with non-existent email" do
    result = Auth::LoginService.call(email: "nonexistent@example.com", password: "password")

    assert_not result[:success]
    assert_equal "Invalid email or password", result[:error]
  end

  test "call stores refresh_token in Redis" do
    result = Auth::LoginService.call(email: @user.email, password: "password")
    refresh_token = result[:payload][:refresh_token]
    stored_user_id = $redis.get("refresh_token:#{refresh_token}")

    assert_equal @user.id.to_s, stored_user_id
  end
end
