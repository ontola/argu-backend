require 'test_helper'

class FlowControllerTest < ActionDispatch::IntegrationTest
  let!(:freetown) { FactoryGirl.create(:forum, name: 'freetown') }
  let(:subject) { FactoryGirl.create(:motion, forum: freetown) }

  ####################################
  # As Guest
  ####################################

  test 'guest should get motion/flow' do
    get motion_flow_path(subject),
        format: :json

    assert_response 200
  end

  ####################################
  # As User
  ####################################
  let(:user) { FactoryGirl.create(:user) }

  test 'user should get motion/flow' do
    #sign_in user

    get motion_flow_path(subject),
        motion_id: subject,
        format: :json

    assert_response 200
  end

  ####################################
  # As Member
  ####################################

  ####################################
  # As Owner
  ####################################

  ####################################
  # As Staff
  ####################################
end
