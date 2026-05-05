class Auth::LogoutService
  def self.call(refresh_token:)
    Auth::TokenService.revoke_refresh_token(refresh_token)
  end
end
