module Api
  module Auth
    class SessionsController < ApplicationController
      def create
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          # TODO: リフレッシュトークンの実装
          access_token = JsonWebToken.encode(user_id: user.id)
          refresh_token = "dummy-refresh-token" # 仮実装

          render json: { uuid: user.uuid, access_token: access_token, refresh_token: refresh_token }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end
    end
  end
end