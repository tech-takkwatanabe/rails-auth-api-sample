class Auth::TokenService
  REFRESH_TOKEN_EXPIRY = 7.days.to_i
  REFRESH_TOKEN_PREFIX = "refresh_token:".freeze

  # アクセストークン + リフレッシュトークンをペアで生成し、Redisに保存
  def self.issue_tokens(user)
    access_token  = JsonWebToken.encode(user_id: user.id)
    refresh_token = SecureRandom.hex(32)
    redis.set("#{REFRESH_TOKEN_PREFIX}#{refresh_token}", user.id, ex: REFRESH_TOKEN_EXPIRY)
    { access_token: access_token, refresh_token: refresh_token }
  end

  # リフレッシュトークンをRedisから削除
  def self.revoke_refresh_token(token)
    redis.del("#{REFRESH_TOKEN_PREFIX}#{token}")
  end

  # リフレッシュトークンをRedisからアトミックに取得・削除し、対応するUserを返す
  # トークンが無効な場合はnilを返す
  def self.consume_refresh_token(token)
    user_id = redis.getdel("#{REFRESH_TOKEN_PREFIX}#{token}")
    return nil unless user_id

    User.find_by(id: user_id)
  end

  def self.redis
    $redis
  end
end
