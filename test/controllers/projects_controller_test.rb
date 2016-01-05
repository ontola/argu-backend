require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @freetown, @freetown_owner = create_forum_owner_pair
  end

  let!(:freetown) { FactoryGirl.create(:forum, :with_follower, name: 'freetown') }
  subject do
    FactoryGirl.create(:project)
  end

  ####################################
  # As Guest
  ####################################

  ####################################
  # As User
  ####################################

  ####################################
  # As Member
  ####################################

  ####################################
  # As Owner
  ####################################

  ####################################
  # As Manager
  ####################################


  ####################################
  # As Staff
  ####################################

end
