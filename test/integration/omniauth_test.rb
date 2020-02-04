# frozen_string_literal: true

require 'test_helper'

class OmniauthTest < ActionDispatch::IntegrationTest
  include UsersHelper
  include JWTHelper

  define_freetown
  let(:guest_user) { GuestUser.new(id: session.id) }
  let(:other_guest_user) { GuestUser.new(id: 'other_id') }
  let(:user) { create(:user, password: 'useruser', password_confirmation: 'useruser') }
  let(:secondary_email) { create(:email_address, user: user, email: 'secondary@argu.co') }
  let(:other_user) { create(:user, password: 'useruser', password_confirmation: 'useruser') }
  let!(:user_fb_only) do
    create(:user,
           :no_password,
           email: 'user_fb_only@argu.co',
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
  let(:motion) { create(:motion, parent: freetown) }
  let(:guest_vote) do
    create(:vote, parent: motion.default_vote_event, creator: guest_user.profile, publisher: guest_user)
  end
  let(:other_guest_vote) do
    create(:vote,
           parent: motion.default_vote_event,
           creator: other_guest_user.profile,
           publisher: other_guest_user)
  end

  ####################################
  # Guest existing identity
  ####################################
  test 'guest should sign in with facebook' do
    facebook_mock(email: 'user_fb_only@argu.co', uid: fb_user_identity.uid)
    visit_facebook_oauth_path(
      expected_r: "/#{argu.url}/",
      favorites: 1,
      votes: 1
    )
  end

  test 'guest should sign in with facebook with r' do
    facebook_mock(email: 'user_fb_only@argu.co', uid: fb_user_identity.uid)

    visit_facebook_oauth_path(
      expected_r: "/#{argu.url}#{user_path(user)}",
      favorites: 1,
      r: user_path(user),
      votes: 1
    )
  end

  test 'guest should sign in with facebook with tenantized r' do
    facebook_mock(email: 'user_fb_only@argu.co', uid: fb_user_identity.uid)

    visit_facebook_oauth_path(
      expected_r: "/#{argu.url}#{user_path(user)}",
      favorites: 1,
      r: "/#{argu.url}#{user_path(user)}",
      votes: 1
    )
  end

  test 'guest should sign in with facebook with encoded r' do
    facebook_mock(email: 'user_fb_only@argu.co', uid: fb_user_identity.uid)
    r = "#{new_iri(motion, :comments)}?comment%5Bbody%5D=this+is+a+text"
    visit_facebook_oauth_path(expected_r: r, favorites: 1, r: r, votes: 1)
    follow_redirect!
    assert_select '.comment_form textarea', 'this is a text'
  end

  test 'guest should sign in with facebook with wrong r' do
    facebook_mock(email: 'user_fb_only@argu.co', uid: fb_user_identity.uid)

    visit_facebook_oauth_path(favorites: 1, votes: 1, r: 'https://evil.co', expected_r: "/#{argu.url}/")
  end

  ####################################
  # Guest existing email
  ####################################
  test 'guest should connect identity to existing user' do
    facebook_mock(email: user.email)
    visit_facebook_oauth_path(
      identities: 1,
      expected_r: proc { connect_user_path(user, token: identity_token(Identity.last)) }
    )
    follow_redirect!
    assert_response 200

    post connect_user_path(user, token: identity_token(Identity.last)),
         params: {
           user: {
             password: 'useruser'
           }
         }
    assert_redirected_to root_path

    assert_equal user.reload.identities.first.access_token,
                 'EAANZAZBdAOGgUBADbu25EDEen6EXgLfTFGN28R6G9E0vgDQEsLuFEMDBNe7v7jUpRCmb4SmSQ'\
                 'qcam37vnKszs80z28WBdJEiBHnHmZCwr3Fv33v1w5jvGZBE6ACZCZBmqkTewz65Deckyyf9br4'\
                 'Nsxz5dSZAQBJ8uqtFEEEj01ncwZDZD'
  end

  test 'guest should connect identity with secondary email to existing user' do
    facebook_mock(email: secondary_email.email)
    visit_facebook_oauth_path(
      identities: 1,
      expected_r: proc { connect_user_path(user, token: identity_token(Identity.last)) }
    )
    follow_redirect!
    assert_response 200

    post connect_user_path(user, token: identity_token(Identity.last)),
         params: {
           user: {
             password: 'useruser'
           }
         }
    assert_redirected_to root_path

    assert_equal user.reload.identities.first.access_token,
                 'EAANZAZBdAOGgUBADbu25EDEen6EXgLfTFGN28R6G9E0vgDQEsLuFEMDBNe7v7jUpRCmb4SmSQ'\
                 'qcam37vnKszs80z28WBdJEiBHnHmZCwr3Fv33v1w5jvGZBE6ACZCZBmqkTewz65Deckyyf9br4'\
                 'Nsxz5dSZAQBJ8uqtFEEEj01ncwZDZD'
  end

  test 'guest should not connect identity to other user' do
    facebook_mock(email: user.email)
    visit_facebook_oauth_path(
      identities: 1,
      expected_r: proc { connect_user_path(user, token: identity_token(Identity.last)) }
    )
    get connect_user_path(other_user, token: identity_token(Identity.last))
    assert_response 200
    post connect_user_path(other_user, token: identity_token(Identity.last)),
         params: {
           user: {
             password: 'useruser'
           }
         }
    assert_response 200
    assert_equal user.reload.identities.count, 0
    assert_equal other_user.reload.identities.count, 0
  end

  ####################################
  # Guest new identity
  ####################################
  test 'guest should sign up with facebook' do
    facebook_mock

    visit_facebook_oauth_path(
      emails: 1,
      expected_r: "/#{argu.url}#{setup_users_path}",
      favorites: 1,
      identities: 1,
      users: 1,
      votes: 1
    )

    assert User.last.confirmed?
    assert User.last.accepted_terms?
    assert_nil User.last.primary_email_record.confirmation_token

    follow_redirect!
    assert_response 200

    put setup_users_path,
        params: {
          user: {
            shortname_attributes: {
              shortname: 'test_user'
            }
          }
        }

    assert_redirected_to setup_path
  end

  test 'guest should sign up with facebook with valid r' do
    facebook_mock

    visit_facebook_oauth_path(
      emails: 1,
      expected_r: "/#{argu.url}/#{user_path(user)}",
      favorites: 1,
      identities: 1,
      r: "/#{argu.url}/#{user_path(user)}",
      users: 1,
      votes: 1
    )
  end

  test 'guest should sign up with facebook with wrong r' do
    facebook_mock

    visit_facebook_oauth_path(
      emails: 1,
      expected_r: "/#{argu.url}#{setup_users_path}",
      favorites: 1,
      identities: 1,
      r: 'https://evil.co',
      users: 1,
      votes: 1
    )
  end

  test 'guest should not sign up with facebook without email' do
    facebook_mock(email: '')

    visit_facebook_oauth_path(expected_r: new_user_registration_path)
    assert_equal flash[:notice], 'We couldn\'t log you in with Facebook. Please try something else.'
  end

  ####################################
  # User existing identity
  ####################################
  test 'user should not add existing identity' do
    facebook_mock(email: 'user_fb_only@argu.co', uid: fb_user_identity.uid)
    sign_in user
    visit_facebook_oauth_path(expected_r: root_path)
    assert_equal(
      flash[:error],
      'Email is different from the one you are currently using. Please log out before signing in with a different one.'
    )
  end

  test 'user should not add own identity' do
    facebook_mock(email: 'user_fb_only@argu.co', uid: fb_user_identity.uid)
    sign_in user_fb_only
    visit_facebook_oauth_path(expected_r: root_path)
    assert_equal flash[:error], 'You are already authenticated.'
  end

  ####################################
  # User existing email
  ####################################
  test 'user should add identity for own email' do
    facebook_mock(email: user.email)
    sign_in user
    visit_facebook_oauth_path(expected_r: root_path, identities: 1)
  end

  test 'user should not add identity for other users email' do
    facebook_mock(email: 'user_fb_only@argu.co')
    sign_in user
    visit_facebook_oauth_path(expected_r: root_path)
    assert_equal(
      flash[:error],
      'Email is different from the one you are currently using. Please log out before signing in with a different one.'
    )
  end

  ####################################
  # User new identity
  ####################################
  test 'user should add identity' do
    facebook_mock
    sign_in user
    visit_facebook_oauth_path(identities: 1, emails: 1, expected_r: root_path)
  end

  test 'user should not add identity without email' do
    facebook_mock(email: '')
    sign_in user
    visit_facebook_oauth_path(expected_r: new_user_registration_path)
    assert_equal flash[:notice], 'We couldn\'t log you in with Facebook. Please try something else.'
  end

  private

  def facebook_mock(email: 'user@argu.co', first_name: 'Firstname', last_name: 'Lastname', uid: '1119134323213')
    OmniAuth.config.mock_auth[:facebook] =
      facebook_auth_hash(
        uid: uid,
        email: email,
        first_name: first_name,
        last_name: last_name,
        middle_name: nil
      )
    facebook_me(fields: {email: email})
    facebook_me(fields: {name: 'My Name'})
  end

  def setup_users_iri
    "#{argu.iri}#{setup_users_path}"
  end

  def visit_facebook_oauth_path(opts) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    post "#{argu.iri}#{user_facebook_omniauth_authorize_path(r: opts[:r])}"
    assert_redirected_to "#{argu.iri.to_s.sub('http', 'https')}#{user_facebook_omniauth_callback_path}"

    guest_vote
    other_guest_vote

    differences = {
      'EmailAddress.count' => opts[:emails] || 0,
      'Favorite.count' => opts[:favorites] || 0,
      'Identity.count' => opts[:identities] || 0,
      'User.count' => opts[:users] || 0,
      'Vote.count' => opts[:votes] || 0
    }

    assert_difference(differences) do
      Sidekiq::Testing.inline! do
        follow_redirect!
        assert_redirected_to opts[:expected_r]
      end
    end
  end
end
