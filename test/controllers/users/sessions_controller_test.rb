require 'test_helper'

class Users::SessionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'should login' do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    post :create, user: {
                    email: users(:user).email,
                    password: 'useruser'
                  }
    assert_redirected_to root_path
  end

  test 'should login with r' do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    post :create, user: {
                    email: users(:user).email,
                    password: 'useruser',
                    r: forum_path(:utrecht)
                }
    assert_redirected_to 'http://test.host/utrecht?'
  end
end
