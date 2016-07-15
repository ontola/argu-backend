# frozen_string_literal: true
require 'test_helper'

class Users::SessionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let(:user) { create(:user) }
  define_freetown

  test 'should login' do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    post :create, user: {
                    email: user.email,
                    password: 'password'
                  }
    assert_redirected_to root_path
  end

  test 'should login with r' do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    post :create, user: {
                    email: user.email,
                    password: 'password',
                    r: forum_path(freetown)
                }
    assert_redirected_to 'http://test.host/freetown?'
  end
end
