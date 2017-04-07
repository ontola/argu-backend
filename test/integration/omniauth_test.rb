# frozen_string_literal: true
require 'test_helper'

class OmniauthTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  define_freetown
  let!(:user3) do
    create(:user,
           email: 'user3@argu.co',
           finished_intro: true,
           first_name: 'User3',
           last_name: 'Lastname3',
           password: 'useruser',
           password_confirmation: 'useruser',
           confirmed_at: Time.current)
  end
  let(:user2) { create(:user) }
  let!(:user_fb_only) do
    create(:user,
           email: 'user_fb_only@argu.co',
           encrypted_password: '',
           finished_intro: true,
           first_name: 'First',
           last_name: 'Lastname_facebook',
           confirmed_at: Time.current)
  end
  let!(:fb_user_identity) do
    create(:identity,
           provider: :facebook,
           uid: 111_903_726_898_977,
           user: user_fb_only)
  end

  test 'should sign up with facebook' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash
    Identity.any_instance.stubs(:email).returns('testuser@example.com')
    Identity.any_instance.stubs(:name).returns('First Last')
    Identity.any_instance.stubs(:image_url).returns('')

    get user_facebook_omniauth_authorize_path
    assert_redirected_to user_facebook_omniauth_callback_path

    assert_differences [['User.count', 1], ['Favorite.count', 1]] do
      follow_redirect!
      assert_redirected_to setup_users_path
      assert_analytics_collected('registrations', 'create', 'facebook')
    end

    assert User.last.confirmed?

    follow_redirect!
    assert_response 200
    assert assigns(:user)

    put setup_users_path,
        params: {
          user: {
            shortname_attributes: {
              shortname: 'test_user'
            }
          }
        }

    assert_redirected_to root_path
    follow_redirect!

    assert_redirected_to forum_path('freetown')
    follow_redirect!
    assert_response 200
  end

  test 'should sign in with facebook' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash(email: 'user_fb_only@argu.co',
                                                              uid: '111903726898977')
    Identity.any_instance.stubs(:email).returns('user_fb_only@argu.co')
    Identity.any_instance.stubs(:name).returns('First Last')
    Identity.any_instance.stubs(:image_url).returns('')

    get user_facebook_omniauth_authorize_path
    assert_redirected_to user_facebook_omniauth_callback_path
    follow_redirect!
    assert_redirected_to root_path
    follow_redirect!
    assert_redirected_to forum_path('freetown')
  end

  test 'should sign in with facebook with r' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash(email: 'user_fb_only@argu.co',
                                                              uid: '111903726898977')
    Identity.any_instance.stubs(:email).returns('user_fb_only@argu.co')
    Identity.any_instance.stubs(:name).returns('First Last')
    Identity.any_instance.stubs(:image_url).returns('')

    get user_facebook_omniauth_authorize_path(r: user_path(user2))
    assert_redirected_to user_facebook_omniauth_callback_path(r: user_path(user2))
    follow_redirect!
    assert_redirected_to user_path(user2)
  end

  test 'should connect to facebook' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash(uid: '1119134323213',
                                                              email: 'user3@argu.co',
                                                              first_name: 'User3',
                                                              last_name: 'Lastname3',
                                                              middle_name: nil)
    Identity.any_instance.stubs(:email).returns('user3@argu.co')
    Identity.any_instance.stubs(:name).returns('User3 Lastname3')
    Identity.any_instance.stubs(:image_url).returns('')

    get user_facebook_omniauth_authorize_path
    assert_redirected_to user_facebook_omniauth_callback_path

    follow_redirect!
    assert_redirected_to connect_user_path(
      user3,
      token: identity_token(Identity.find_by(uid: 1_119_134_323_213))
    )

    follow_redirect!
    assert_response 200

    post connect_user_path(user3, token: identity_token(Identity.find_by(uid: 1_119_134_323_213))),
         params: {
           user: {
             password: 'useruser'
           }
         }
    assert_redirected_to root_path
    assert_equal user3.reload.identities.first.access_token,
                 'EAANZAZBdAOGgUBADbu25EDEen6EXgLfTFGN28R6G9E0vgDQEsLuFEMDBNe7v7jUpRCmb4SmSQ'\
                 'qcam37vnKszs80z28WBdJEiBHnHmZCwr3Fv33v1w5jvGZBE6ACZCZBmqkTewz65Deckyyf9br4'\
                 'Nsxz5dSZAQBJ8uqtFEEEj01ncwZDZD'
  end

  test 'should not connect different accounts to facebook' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash(uid: '1119134323213',
                                                              email: 'user3@argu.co',
                                                              first_name: 'User3',
                                                              last_name: 'Lastname3',
                                                              middle_name: nil)
    Identity.any_instance.stubs(:email).returns('user3@argu.co')
    Identity.any_instance.stubs(:name).returns('User3 Lastname3')
    Identity.any_instance.stubs(:image_url).returns('')

    get user_facebook_omniauth_authorize_path
    assert_redirected_to user_facebook_omniauth_callback_path

    follow_redirect!
    assert_redirected_to connect_user_path(
      user3,
      token: identity_token(Identity.find_by(uid: 1_119_134_323_213))
    )

    get connect_user_path(user2, token: identity_token(Identity.find_by(uid: 1_119_134_323_213)))
    assert_response 200

    post connect_user_path(user2,
                           token: identity_token(Identity.find_by(uid: 1_119_134_323_213))),
         params: {
           user: {
             password: 'useruser'
           }
         }
    assert_response 200
    assert_not_equal user2, assigns(:identity).user
    assert_equal nil, assigns(:identity).user
  end
end
