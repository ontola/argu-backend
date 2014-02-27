require "spec_helper"

describe StatementargumentsController do
  describe "routing" do

    it "routes to #index" do
      get("/statementarguments").should route_to("statementarguments#index")
    end

    it "routes to #new" do
      get("/statementarguments/new").should route_to("statementarguments#new")
    end

    it "routes to #show" do
      get("/statementarguments/1").should route_to("statementarguments#show", :id => "1")
    end

    it "routes to #edit" do
      get("/statementarguments/1/edit").should route_to("statementarguments#edit", :id => "1")
    end

    it "routes to #create" do
      post("/statementarguments").should route_to("statementarguments#create")
    end

    it "routes to #update" do
      put("/statementarguments/1").should route_to("statementarguments#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/statementarguments/1").should route_to("statementarguments#destroy", :id => "1")
    end

  end
end
