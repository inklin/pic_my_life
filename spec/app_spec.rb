ENV['DATABASE'] = "test"
require "rspec"
require "rack/test"
require "./config/environment"
require "./app/actions"
require_relative "spec_helper"


describe "Sinatra App" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe "GET '/'" do

    it "loads home page" do
      get "/"
      expect(last_response).to be_ok
    end

    it "displays home page content" do
      get "/"
      expect(last_response.body).to include("Sign Up")
    end
  end
 
  describe "GET '/photos'" do

    it "loads photos page" do
      get "/photos"
      expect(last_response).to be_ok
    end

    it "displays photos content" do
      get "/photos"
      expect(last_response.body).to include("photowall")
    end
  end

  describe "GET '/photos/new'" do
    
    it "loads new photo page" do
      get "/photos/new"
      expect(last_response).to be_ok
    end

    it "loads new photo content" do
      get "/photos/new"
      expect(last_response.body).to include("Post a Picture")
    end
  end

  describe "GET '/photos/:id'" do

    it "loads individual photo page" do
      @photo = FactoryGirl.create :photo
      get "/photos/#{@photo.id}"
      expect(last_response.body).to include(@photo.caption)
    end
  end

  describe "GET '/signup'" do

    it "loads signup page" do
      get "/signup"
      expect(last_response).to be_ok
    end

    it "displays signup page content" do
      get "/signup"
      expect(last_response.body).to include("Sign Up")
    end
  end

  describe "POST '/signup'" do

    it "should redirect to photos if params are valid" do
      post "/signup", { user: { username: "Lucy", password: "something", password_confirmation: "something"}}
      expect(last_response.redirect?).to be true
      follow_redirect!
      expect(last_request.url).to eq("http://example.org/photos")
    end

    it "should not redirect if params are invalid" do
      post "/signup", { user: { username: "Lucy", password: "something", password_confirmation: "some"}}
      expect(last_response.redirect?).to be false
    end

    it "should have entered username if params are invalid" do
      post "/signup", { user: { username: "Lucy", password: "something", password_confirmation: "some"}}
      expect(last_response.body).to include("Lucy")
    end
  end

  describe "GET '/signin'" do

    it "loads signin page" do
      get "/signin"
      expect(last_response).to be_ok
    end

    it "loads signin page content" do
      get "/signin"
      expect(last_response.body).to include("Sign In")
    end
  end

  describe "POST '/signin'" do

    it "should redirect to photos page if signin is valid" do
      @user = User.create(username: "fake", password: "mypassword", password_confirmation: "mypassword")
      post '/signin', { user: { username: "fake", password: "mypassword" } }
      expect(last_response.redirect?).to be true
    end
  end

  describe "GET '/signout'" do

    it "redirects to photos page" do
      get "/signout"
      expect(last_response.redirect?).to be true
      follow_redirect!
      expect(last_request.url).to eq("http://example.org/photos")
    end

  end

  describe "POST '/photos/:id/votes'" do

    it "creates a new vote and redirects to photos page" do
      @user = User.create(username: "fake", password: "mypassword", password_confirmation: "mypassword")
      post '/signin', { user: { username: "fake", password: "mypassword" } }
      @photo = FactoryGirl.create :photo, user_id: @user.id
      post "/photos/#{@photo.id}/votes", { choice: "funny" }
      expect(Vote.where(user_id: @user.id, photo_id: @photo.id).count).to eq(1)
      expect(last_response.redirect?).to be true
    end
  end

end