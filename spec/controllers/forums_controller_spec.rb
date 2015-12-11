require "rails_helper"

RSpec.describe ForumsController, :type => :controller do
  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the forums template" do
      get :index
      expect(response).to render_template("forums")
    end

    it "loads all of the forums into @forums" do
      forum1, forum2 = Forum.create!(name: "one"), Forum.create!(name: "two")
      get :index

      expect(assigns(:forums)).to match_array([forum1, forum2])
    end
  end

  describe "GET #new" do
    it "responds successfully with an HTTP 200 status code" do
      get :new
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the forums template" do
      get :new
      expect(response).to render_template("forums")
    end
  end

end