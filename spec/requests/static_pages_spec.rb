require 'spec_helper'

describe "StaticPages" do

  describe "Home page" do
    it "works" do
      get root_path
      response.status.should be(200)
    end
  end

end
