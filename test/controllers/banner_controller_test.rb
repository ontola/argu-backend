require 'test_helper'

class BannerControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:holland) { FactoryGirl.create(:populated_forum,
                                      name: 'holland') }
  let!(:unpublished_banner) { FactoryGirl.create(:banner,
                                                 :unpublished,
                                                 title: 'unpublished_banner') }
  let!(:banner_everyone) { FactoryGirl.create(:banner,
                                                 :published, :everyone,
                                                 title: 'banner_everyone') }

  ####################################
  # For Guests
  ####################################
  test '' do

  end

  ####################################
  # For Users
  ####################################

  ####################################
  # For Members
  ####################################


end
