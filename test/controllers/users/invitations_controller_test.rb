require 'test_helper'

class Users::InvitationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let(:user) { create(:user) }
  let(:freetown) { create(:forum) }

  ####################################
  # As User
  ####################################
  test 'should be able to show invite' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in user

    get :new, forum: freetown
    assert_response :success
  end
end
