# frozen_string_literal: true

require 'test_helper'

class OmniauthTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  define_freetown
  let(:guest_user) { GuestUser.new(session: session) }
  let(:other_guest_user) { GuestUser.new(id: 'other_id') }
  let!(:user3) do
    create(:user,
           email: 'user3@argu.co',
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
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:guest_vote) do
    create(:vote, parent: motion.default_vote_event.edge, creator: guest_user.profile, publisher: guest_user)
  end
  let(:other_guest_vote) do
    create(:vote,
           parent: motion.default_vote_event.edge,
           creator: other_guest_user.profile,
           publisher: other_guest_user)
  end

  test 'should sign up with facebook' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash
    Identity.any_instance.stubs(:email).returns('testuser@example.com')
    Identity.any_instance.stubs(:name).returns('First Last')
    Identity.any_instance.stubs(:image_url).returns('')

    get user_facebook_omniauth_authorize_path
    assert_redirected_to user_facebook_omniauth_callback_path

    guest_vote
    other_guest_vote

    assert_differences [['User.count', 1], ['Identity.count', 1], ['Vote.count', 1], ['Favorite.count', 1]] do
      Sidekiq::Testing.inline! do
        follow_redirect!
        assert_redirected_to setup_users_path
        assert_analytics_collected('registrations', 'create', 'facebook')
      end
    end

    assert User.last.confirmed?
    assert_nil User.last.primary_email_record.confirmation_token

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

    assert_redirected_to setup_profiles_path
  end

  test 'should not sign up with facebook without email' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash(email: '')
    cookies[:locale] = 'en'

    get user_facebook_omniauth_authorize_path(r: user_path(user2))
    assert_redirected_to user_facebook_omniauth_callback_path(r: user_path(user2))

    assert_differences [['User.count', 0], ['Identity.count', 0]] do
      Sidekiq::Testing.inline! do
        follow_redirect!
        assert_redirected_to new_user_registration_path(r: user_path(user2))
        assert_equal flash[:notice], 'We couldn\'t log you in with Facebook. Please try something else.'
      end
    end
  end

  test 'should sign up with facebook with wrong r' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash
    Identity.any_instance.stubs(:email).returns('testuser@example.com')
    Identity.any_instance.stubs(:name).returns('First Last')
    Identity.any_instance.stubs(:image_url).returns('')

    get user_facebook_omniauth_authorize_path(r: 'https://evil.co')
    assert_redirected_to user_facebook_omniauth_callback_path(r: 'https://evil.co')

    assert_difference 'User.count', 1 do
      follow_redirect!
      assert_redirected_to setup_users_path
      assert_analytics_collected('registrations', 'create', 'facebook')
    end
  end

  test 'should sign in with facebook' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash(email: 'user_fb_only@argu.co',
                                                              uid: '111903726898977')
    Identity.any_instance.stubs(:email).returns('user_fb_only@argu.co')
    Identity.any_instance.stubs(:name).returns('First Last')
    Identity.any_instance.stubs(:image_url).returns('')

    get user_facebook_omniauth_authorize_path
    assert_redirected_to user_facebook_omniauth_callback_path
    guest_vote
    other_guest_vote

    assert_differences [['User.count', 0], ['Vote.count', 1], ['Favorite.count', 1]] do
      Sidekiq::Testing.inline! do
        follow_redirect!
        assert_redirected_to root_path
      end
    end
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
    guest_vote
    other_guest_vote

    assert_differences [['User.count', 0], ['Vote.count', 1], ['Favorite.count', 1], ['Identity.count', 1]] do
      Sidekiq::Testing.inline! do
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
      end
    end

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
