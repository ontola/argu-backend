require 'spec_helper'

describe "UserPages" do
  describe "GET /user_pages" do
    it "works" do
      get user_pages_index_path
      response.status.should be(200)
    end
  end
end
