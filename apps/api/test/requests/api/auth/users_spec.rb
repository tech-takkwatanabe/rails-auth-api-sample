require 'rails_helper'

RSpec.describe "Api::Auth::Users", type: :request do
  describe "POST /api/auth/signup" do
    context "with valid parameters" do
      let(:valid_params) do
        { user: { name: "testuser", email: "test@example.com", password: "password", password_confirmation: "password" } }
      end

      it "creates a new user" do
        expect { post "/api/auth/signup", params: valid_params }.to change(User, :count).by(1)
      end

      it "returns a created status" do
        post "/api/auth/signup", params: valid_params
        expect(response).to have_http_status(:created)
      end

      it "returns the user's uuid, name, and email" do
        post "/api/auth/signup", params: valid_params
        json_response = JSON.parse(response.body)
        expect(json_response).to include("uuid", "name", "email")
        expect(json_response['name']).to eq("testuser")
        expect(json_response['email']).to eq("test@example.com")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { user: { name: "testuser", email: "test@example.com", password: "password", password_confirmation: "wrong_password" } }
      end

      it "does not create a new user" do
        expect { post "/api/auth/signup", params: invalid_params }.not_to change(User, :count)
      end

      it "returns an unprocessable entity status" do
        post "/api/auth/signup", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an error message" do
        post "/api/auth/signup", params: invalid_params
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("errors")
      end
    end
  end
end
