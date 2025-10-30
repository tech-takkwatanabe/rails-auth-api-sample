module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    decoded = JsonWebToken.decode(token)
    if decoded
      @current_user = User.find(decoded[:user_id])
    else
      render json: { errors: ['Invalid or missing token'] }, status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ['User not found'] }, status: :unauthorized
  end
end
