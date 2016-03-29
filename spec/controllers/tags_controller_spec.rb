require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  before(:each) do
    @tag = FactoryGirl.create(:tag)
  end
  describe "GET #create" do
    it "returns http success" do
      post :create, {tag: @tag}
      expect(response).to have_http_status(:success)
    end
  end

  

  describe "GET #destroy" do
    it "returns http success" do
      delete :destroy, id: @tag.id
      expect(response).to have_http_status(:success)
    end
  end

end
