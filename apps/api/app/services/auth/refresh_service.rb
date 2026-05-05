class Auth::RefreshService
  def self.call(refresh_token:)
    user = Auth::TokenService.consume_refresh_token(refresh_token)

    unless user
      return { success: false, error: "Invalid refresh token" }
    end

    # 新しいトークンペアを生成
    tokens = Auth::TokenService.issue_tokens(user)

    {
      success: true,
      payload: {
        access_token: tokens[:access_token],
        refresh_token: tokens[:refresh_token]
      }
    }
  end
end
