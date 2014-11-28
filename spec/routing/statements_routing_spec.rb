require "spec_helper"

describe MotionsController do
  describe "routing" do

    it "routes to #index" do
      get("/motions").should route_to("motions#index")
    end

    it "routes to #new" do
      get("/motions/new").should route_to("motions#new")
    end

    it "routes to #show" do
      get("/motions/1").should route_to("motions#show", :id => "1")
    end

    it "routes to #edit" do
      get("/motions/1/edit").should route_to("motions#edit", :id => "1")
    end

    it "routes to #create" do
      post("/motions").should route_to("motions#create")
    end

    it "routes to #update" do
      put("/motions/1").should route_to("motions#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/motions/1").should route_to("motions#destroy", :id => "1")
    end

  end
end
