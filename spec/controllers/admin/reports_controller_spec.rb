require 'rails_helper'

RSpec.describe Admin::ReportsController, type: :controller do

  describe "GET #index without admin role" do
    it "returns http status of 302" do
      get :index
      expect(response).to have_http_status(302)
    end

    it 'redirect_to root path' do
      get :index
      expect(response).to redirect_to root_path
    end
  end

  describe 'access user' do
    before :each do
      @user = create(:admin)
      
      session[:user_id] = @user.id
    end
    describe "Get #index with admin role" do


      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'render index template' do
        get :index
        expect(response).to render_template "admin"
      end

      it 'collects user to @users' do
        user = create(:user)
        
        get :index
        expect(assigns(:users)).to match_array [user, @user]
      end
    end
  end


end
