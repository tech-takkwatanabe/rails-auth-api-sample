module Api
  module Auth
    class UsersController < ApplicationController
      include Authenticable
      skip_before_action :authenticate_request!, only: [:create]

      def create
        user = User.new(user_params)
        if user.save
          render json: { uuid: user.uuid, name: user.name, email: user.email }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def me
        render json: { uuid: @current_user.uuid, name: @current_user.name, email: @current_user.email }, status: :ok
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
