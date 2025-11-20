module Api
  module Auth
    class SessionsController < ApplicationController
      def create
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          access_token = JsonWebToken.encode(user_id: user.id)
          
          # リフレッシュトークンの生成と保存
          refresh_token = SecureRandom.hex(32)
          $redis.set("refresh_token:#{refresh_token}", user.id, ex: 7.days.to_i)

          render json: { uuid: user.uuid, access_token: access_token, refresh_token: refresh_token }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
            end
    end
  end
end
