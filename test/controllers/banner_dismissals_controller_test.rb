require 'test_helper'

class BannerDismissalsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }
end
