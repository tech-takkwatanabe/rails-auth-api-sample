class Auth::LoginService
  def self.call(email:, password:)
    user = User.find_by(email: email)

    unless user&.authenticate(password)
      return { success: false, error: "Invalid email or password" }
    end

    tokens = Auth::TokenService.issue_tokens(user)

    {
      success: true,
      payload: {
        uuid: user.uuid,
        access_token: tokens[:access_token],
        refresh_token: tokens[:refresh_token]
      }
    }
  end
end
