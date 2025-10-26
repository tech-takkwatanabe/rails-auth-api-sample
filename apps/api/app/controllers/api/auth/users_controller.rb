module Api
  module Auth
    class UsersController < ApplicationController
      def create
        user = User.new(user_params)
        if user.save
          render json: { uuid: user.uuid, name: user.name, email: user.email }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
