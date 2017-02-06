# frozen_string_literal: true
require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  include ProfilesHelper

  let(:user) { create(:user) }
  let(:user2) { create(:user) }

  ####################################
  # As User
  ####################################
  test 'user should put setup' do
    sign_in user

    put :setup!,
        params: {
          id: user.url,
          user: attributes_for(:user).merge(
            profile_attributes: {
              id: user.profile.id,
              default_profile_photo_attributes: {
                id: user.profile.default_profile_photo.id,
                content: fixture_file_upload('profile_photo.png', 'image/png'),
                used_as: 'profile_photo'
              },
              default_cover_photo_attributes: {
                content: fixture_file_upload('cover_photo.jpg', 'image/jpg'),
                used_as: 'cover_photo'
              }
            }
          )
        }
    user.profile.reload
    assert_equal 'profile_photo.png', user.profile.default_profile_photo.content_identifier
    assert_equal 'cover_photo.jpg', user.profile.default_cover_photo.content_identifier
    assert_redirected_to user_path(user)
  end

  test 'user should get edit profile with own profile' do
    sign_in user

    get :edit, params: {id: user.url}

    assert_redirected_to settings_path(tab: :profile)
    assert_equal user, assigns(:resource), ''
  end

  test 'user should not get edit profile with other profile' do
    sign_in user

    get :edit, params: {id: user2.url}

    assert_response 403
    assert_equal user2, assigns(:resource)
  end
end
