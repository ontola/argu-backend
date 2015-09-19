require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  include TestHelper
  include Devise::TestHelpers

  ####################################
  # Not logged in
  ####################################

  test 'should post create' do
    user_params = attributes_for(:user)
    @request.env['devise.mapping'] = Devise.mappings[:user]

    assert_differences([['User.count', 1],
                        ['Membership.count', 1]]) do
      post :create,
           user: {
               email: user_params[:email],
               password: user_params[:password],
               password_confirmation: user_params[:password]
           }
    end

    assert_not ActionMailer::Base.deliveries.empty?

    assert_redirected_to setup_users_path
  end

  test "should not post create when passwords don't match" do
    user_params = attributes_for(:user)
    @request.env['devise.mapping'] = Devise.mappings[:user]

    assert_no_difference('User.count') do
      post :create,
           user: {
               email: user_params[:email],
               password: user_params[:password],
               password_confirmation: 'random gibberish'
           }
    end

    assert ActionMailer::Base.deliveries.empty?

    assert_response 200
  end

end
