require "rails_helper"

RSpec.describe GroupbuysController, :type => :controller do

  describe "get #index" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      session[:user_id] = @user.id
    end

    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the application template" do
      get :index
      expect(response).to render_template("index")
    end

    it "loads all of groupbuys which locale is zh into @groupbuys" do
      groupbuy1, groupbuy2 = FactoryGirl.create(:groupbuy), FactoryGirl.create(:groupbuy)
      session[:locale] = 'zh'
      get :index
      expect(assigns(:groupbuys).length).to equal 0
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
      @groupbuy = FactoryGirl.create(:groupbuy)
      get :show, id: @groupbuy.id
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end

    it "renders the application template" do
      @groupbuy = FactoryGirl.create(:groupbuy)
      get :show, id: @groupbuy.id
      expect(response).to render_template("application")
    end
  end

  describe "GET #new" do
    it "responds successfully with an HTTP 200 status code" do
      get :new
      expect(response).to have_http_status(302)
    end

    it "renders the application template" do
      get :new
      expect(response).to redirect_to(register_path(return_url: 'http://test.host/groupbuys/new'))
    end
  end
end