# frozen_string_literal: true
require 'test_helper'

class BannerDismissalsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }
end
