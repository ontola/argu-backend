require "spec_helper"

describe StatementsController do
  describe "routing" do

    it "routes to #index" do
      get("/statements").should route_to("statements#index")
    end

    it "routes to #new" do
      get("/statements/new").should route_to("statements#new")
    end

    it "routes to #show" do
      get("/statements/1").should route_to("statements#show", :id => "1")
    end

    it "routes to #edit" do
      get("/statements/1/edit").should route_to("statements#edit", :id => "1")
    end

    it "routes to #create" do
      post("/statements").should route_to("statements#create")
    end

    it "routes to #update" do
      put("/statements/1").should route_to("statements#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/statements/1").should route_to("statements#destroy", :id => "1")
    end

  end
end
