module Api
  module Auth
    class RefreshesController < ApplicationController
      def create
        result = ::Auth::RefreshService.call(refresh_token: params[:refresh_token])
        if result[:success]
          render json: result[:payload], status: :ok
        else
          render json: { error: result[:error] }, status: :unauthorized
        end
      end
    end
  end
end
