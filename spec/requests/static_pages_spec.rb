require 'spec_helper'

describe "StaticPages" do

  describe "Home page" do
    it "works" do
      get static_pages_index_path + "/home"
      response.status.should be(200)
    end
  end

end
