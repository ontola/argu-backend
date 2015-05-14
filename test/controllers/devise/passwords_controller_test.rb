require 'test_helper'

class Devise::PasswordsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test 'should get new' do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    get :new

    assert_response :success
  end
end