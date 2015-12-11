require 'rails_helper'

RSpec.describe Admin::ReportsController, type: :controller do

  describe "GET #index without admin role" do
    it "returns http fail" do
      get :index
      expect(response).to have_http_status(:fail)
    end
  end

end
