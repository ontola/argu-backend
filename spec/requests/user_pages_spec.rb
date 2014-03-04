require 'spec_helper'

describe "UserPages" do

  before(:all) do
    login_user
  end

  describe "GET /settings" do
    it "works! (now write some real specs)" do
      get settings_path
      response.status.should be(200)
    end
  end
end
