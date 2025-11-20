module Api
  module Auth
    class RefreshesController < ApplicationController
      def create
        refresh_token = params[:refresh_token]
        user_id = $redis.get("refresh_token:#{refresh_token}")

        if user_id
          # 古いリフレッシュトークンを削除
          $redis.del("refresh_token:#{refresh_token}")

          user = User.find(user_id)
          
          # 新しいトークンペアを生成
          new_access_token = JsonWebToken.encode(user_id: user.id)
          new_refresh_token = SecureRandom.hex(32)
          $redis.set("refresh_token:#{new_refresh_token}", user.id, ex: 7.days.to_i)

          render json: { access_token: new_access_token, refresh_token: new_refresh_token }, status: :ok
        else
          render json: { error: 'Invalid refresh token' }, status: :unauthorized
        end
      end
    end
  end
end
