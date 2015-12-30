require "rails_helper"

RSpec.describe GroupbuysController, :type => :controller do
  describe "get #index" do

    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the application template" do
      get :index
      expect(response).to render_template("application")
    end

    it "loads all of groupbuys which locale is zh into @groupbuys" do
      groupbuy1, groupbuy2 = FactoryGirl.create(:groupbuy), FactoryGirl.create(:groupbuy)
      session[:locale] = 'zh'
      get :index
      expect(assigns(:groupbuys).length).to equal 2
    end

    it "it will not load the groupuby which locale is en into @groupbuys" do
      groupbuy1, groupbuy2 = FactoryGirl.create(:groupbuy), FactoryGirl.create(:groupbuy, locale: 'en')
      session[:locale] = 'zh'
      get :index
      expect(assigns(:groupbuys).length).to equal 1
    end
  end

  describe "GET #show" do
    it "responds successfully with an HTTP 200 status code" do
      get :show
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the application template" do
      get :show
      expect(response).to render_template("application")
    end
  end

  describe "GET #new" do
    it "responds successfully with an HTTP 200 status code" do
      get :new
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the application template" do
      get :new
      expect(response).to render_template("application")
    end
  end
end