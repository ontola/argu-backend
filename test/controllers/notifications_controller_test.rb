require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  let!(:freetown) { create(:forum, name: 'freetown') }

  ####################################
  # As Guest
  ####################################

  test 'guest should not get index' do
    get :index

    assert_response 204
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }
  let(:user_with_notifications) do
    create(:user,
           :with_notifications)
  end

  test 'user without notifications should get index no content' do
    sign_in user

    get :index, format: :json

    assert_response 204
  end

  test 'user with notifications should get index' do
    sign_in user_with_notifications

    get :index, format: :json

    assert_response 200
  end
end
