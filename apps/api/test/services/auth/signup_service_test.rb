require "test_helper"

class Auth::SignupServiceTest < ActiveSupport::TestCase
  test "call creates a user with valid params" do
    params = ActionController::Parameters.new(
      name: "newuser", email: "signup-test@example.com", password: "password", password_confirmation: "password"
    ).permit(:name, :email, :password, :password_confirmation)

    result = Auth::SignupService.call(params)

    assert result[:success]
    assert_not_nil result[:user]
    assert_equal "newuser", result[:user].name
    assert_equal "signup-test@example.com", result[:user].email
    assert_not_nil result[:user].uuid
  end

  test "call fails with mismatched password confirmation" do
    params = ActionController::Parameters.new(
      name: "newuser", email: "signup-fail@example.com", password: "password", password_confirmation: "wrong"
    ).permit(:name, :email, :password, :password_confirmation)

    result = Auth::SignupService.call(params)

    assert_not result[:success]
    assert_includes result[:errors], "Password confirmation doesn't match Password"
  end

  test "call fails with missing name" do
    params = ActionController::Parameters.new(
      name: "", email: "no-name@example.com", password: "password", password_confirmation: "password"
    ).permit(:name, :email, :password, :password_confirmation)

    result = Auth::SignupService.call(params)

    assert_not result[:success]
    assert_includes result[:errors], "Name can't be blank"
  end

  test "call fails with duplicate email" do
    User.create!(name: "existing", email: "dup@example.com", password: "password")

    params = ActionController::Parameters.new(
      name: "newuser", email: "dup@example.com", password: "password", password_confirmation: "password"
    ).permit(:name, :email, :password, :password_confirmation)

    result = Auth::SignupService.call(params)

    assert_not result[:success]
    assert_includes result[:errors], "Email has already been taken"
  end
end
