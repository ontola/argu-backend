require 'test_helper'

class Users::InvitationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let(:user) { FactoryGirl.create(:user) }
  let(:freetown) { FactoryGirl.create(:forum) }

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
