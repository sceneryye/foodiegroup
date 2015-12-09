require 'rails_helper'

RSpec.describe Admin::ReportsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'render :index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'assigns the requested user to @user' do
      
    end
  end



end
