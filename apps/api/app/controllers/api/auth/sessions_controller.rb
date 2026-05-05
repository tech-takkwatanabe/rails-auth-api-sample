module Api
  module Auth
    class SessionsController < ApplicationController
      include Authenticable
      skip_before_action :authenticate_request!, only: [:create]

      def create
        result = ::Auth::LoginService.call(email: params[:email], password: params[:password])
        if result[:success]
          render json: result[:payload], status: :ok
        else
          render json: { error: result[:error] }, status: :unauthorized
        end
      end

      def destroy
        ::Auth::LogoutService.call(refresh_token: params[:refresh_token])
        head :no_content
      end
    end
  end
end
