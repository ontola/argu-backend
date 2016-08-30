require 'test_helper'

class FlowControllerTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:subject) { create(:motion, parent: freetown.edge) }

  ####################################
  # As Guest
  ####################################

  test 'guest should get motion/flow' do
    get motion_flow_path(subject),
        params: {format: :json}

    assert_response 200
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get motion/flow' do
    #sign_in user

    get motion_flow_path(subject),
        params: {
          motion_id: subject,
          format: :json
        }

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
