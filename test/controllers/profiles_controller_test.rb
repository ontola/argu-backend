# frozen_string_literal: true

require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  include ProfilesHelper

  define_freetown
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:user_no_shortname) { create(:user, :no_shortname, first_name: nil, last_name: nil) }

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
    assert_redirected_to resource_iri(user, root: argu).to_s
  end

  test 'user should put setup and redirect to token from cookie' do
    sign_in user
    cookies[:token] = argu_url('/tokens/1234')

    put :setup!,
        params: {
          id: user.url,
          user: attributes_for(:user).merge(
            profile_attributes: {
              id: user.profile.id
            }
          )
        }
    assert_redirected_to argu_url('/tokens/1234')
  end

  test 'user should get edit profile with own profile' do
    sign_in user

    get :edit, params: {id: user.url}

    assert_redirected_to settings_iri('/u', tab: :profile)
  end

  test 'user should not get edit profile with other profile' do
    sign_in user

    get :edit, params: {id: user2.url}

    assert_not_authorized
  end

  ####################################
  # As Administrator
  ####################################
  let(:administator) { create_administrator(freetown) }

  test 'administrator should search by shortname' do
    sign_in administator

    post :index,
         params: {
           q: user.url,
           format: :json
         }

    assert_response 200
    assert_equal parsed_body[:profiles].size, 1
  end

  test 'administrator should search by first name' do
    sign_in administator

    post :index,
         params: {
           q: user.first_name,
           format: :json
         }

    assert_response 200
    assert_equal parsed_body[:profiles].size, 1
  end

  test 'administrator should not search by email' do
    sign_in administator

    post :index,
         params: {
           q: user.email,
           format: :json
         }

    assert_response 200
    assert_equal parsed_body[:profiles].size, 0
  end

  test 'administrator should get index non found' do
    sign_in administator

    post :index,
         params: {
           q: 'wrong',
           format: :json
         }

    assert_response 200
    assert_equal parsed_body[:profiles].size, 0
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should not search by email' do
    sign_in staff

    post :index,
         params: {
           q: user.email,
           format: :json
         }

    assert_response 200
    assert_equal parsed_body[:profiles].size, 1
  end

  test 'staff should search user without shortname by email' do
    sign_in staff

    post :index,
         params: {
           q: user_no_shortname.email,
           format: :json
         }

    assert_response 200
    assert_equal parsed_body[:profiles].size, 1
  end
end
