require 'jwt'

class JsonWebToken
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret_key)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret_key)[0]
    HashWithIndifferentAccess.new decoded
  rescue JWT::DecodeError => e
    nil
  end

  def self.secret_key
    ENV['JWT_SECRET_KEY']
  end
end
