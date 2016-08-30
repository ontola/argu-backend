require 'test_helper'

class Users::InvitationsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  define_freetown

  ####################################
  # As User
  ####################################
  test 'should be able to show invite' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in user

    get :new, params: {forum: freetown}
    assert_response :success
  end
end
