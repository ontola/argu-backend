require 'test_helper'

class Users::InvitationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'should be able to show invite' do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in users(:user)

    get :new, forum: forums(:utrecht)
    assert_response :success
  end
end
