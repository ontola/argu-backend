require 'test_helper'

class FlowControllerTest < ActionDispatch::IntegrationTest
  define_common_objects :freetown!, :user, :motion

  ####################################
  # As Guest
  ####################################
  test 'guest should get motion/flow' do
    get motion_flow_path(motion),
        format: :json

    assert_response 200
  end

  ####################################
  # As User
  ####################################
  test 'user should get motion/flow' do
    #sign_in user

    get motion_flow_path(motion),
        motion_id: motion,
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
