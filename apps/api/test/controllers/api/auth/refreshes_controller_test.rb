require "test_helper"

module Api
  module Auth
    class RefreshesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = User.create!(name: "test", email: "refresh@example.com", password: "password")
        @refresh_token = SecureRandom.hex(32)
        $redis.set("refresh_token:#{@refresh_token}", @user.id, ex: 7.days.to_i)
      end

      test "should get new tokens with valid refresh token" do
        post api_auth_refresh_url, params: { refresh_token: @refresh_token }, as: :json
        
        assert_response :ok
        json_response = JSON.parse(response.body)
        assert_not_nil json_response["access_token"]
        assert_not_nil json_response["refresh_token"]
        assert_not_equal @refresh_token, json_response["refresh_token"]

        # 古いトークンがRedisから削除されていることを確認
        assert_nil $redis.get("refresh_token:#{@refresh_token}")
        # 新しいトークンがRedisに存在することを確認
        assert_not_nil $redis.get("refresh_token:#{json_response["refresh_token"]}")
      end

      test "should not get new tokens with invalid refresh token" do
        post api_auth_refresh_url, params: { refresh_token: "invalid_token" }, as: :json
        assert_response :unauthorized
      end

      test "should not get new tokens with used refresh token" do
        # 最初に一度成功させる
        post api_auth_refresh_url, params: { refresh_token: @refresh_token }, as: :json
        assert_response :ok

        # 同じトークンで再度リクエストを送ると失敗することを確認
        post api_auth_refresh_url, params: { refresh_token: @refresh_token }, as: :json
        assert_response :unauthorized
      end
    end
  end
end
