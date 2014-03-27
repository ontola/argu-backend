require "spec_helper"

describe ArgumentsController do
  describe "routing" do

    it "routes to #index" do
      get("/arguments").should route_to("arguments#index")
    end

    it "routes to #new" do
      get("/arguments/new").should route_to("arguments#new")
    end

    it "routes to #show" do
      get("/arguments/1").should route_to("arguments#show", :id => "1")
    end

    it "routes to #edit" do
      get("/arguments/1/edit").should route_to("arguments#edit", :id => "1")
    end

    it "routes to #create" do
      post("/arguments").should route_to("arguments#create")
    end

    it "routes to #update" do
      put("/arguments/1").should route_to("arguments#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/arguments/1").should route_to("arguments#destroy", :id => "1")
    end

  end
end
