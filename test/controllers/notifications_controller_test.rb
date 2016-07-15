# frozen_string_literal: true
require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  define_freetown

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
    sign_in user
    followed_content(user)

    get :index, format: :json

    assert_response 200
  end

  private

  def followed_content(user)
    parent = freetown
    create(:follow, followable: parent.edge, follower: user)
    %i(question motion vote argument comment ).each do |type|
      trackable = create(type, parent: parent.edge)
      if %i(question motion argument).include?(type)
        parent = trackable
        create(:follow, followable: parent.edge, follower: user)
      end
    end
  end
end
