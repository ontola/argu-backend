# frozen_string_literal: true

require 'test_helper'

module Users
  class ConfirmationsTest < ActionDispatch::IntegrationTest
    define_freetown
    let(:user) { create(:unconfirmed_user) }
    let!(:user_without_password) { create(:user, :no_password) }
    let(:other_user) { create(:unconfirmed_user) }
    let(:confirmed_user) { create(:user) }
    let(:motion) { create(:motion, parent: freetown) }
    let(:motion2) { create(:motion, parent: freetown) }
    let(:motion3) { create(:motion, parent: freetown) }
    let(:confirmed_vote) do
      create(:vote, parent: motion.default_vote_event, creator: confirmed_user.profile, publisher: confirmed_user)
    end
    let(:unconfirmed_vote) do
      create(:vote, parent: motion.default_vote_event, creator: user.profile, publisher: user)
    end
    let(:unconfirmed_vote2) do
      create(:vote, parent: motion2.default_vote_event, creator: user.profile, publisher: user)
    end
    let(:other_unconfirmed_vote) do
      create(:vote, parent: motion.default_vote_event, creator: other_user.profile, publisher: other_user)
    end
    let(:other_unconfirmed_vote3) do
      create(:vote, parent: motion3.default_vote_event, creator: other_user.profile, publisher: other_user)
    end

    ####################################
    # As guest
    ####################################
    test 'guest should get show confirmation' do
      assert_not user.confirmed?
      get user_confirmation_path(confirmation_token: user.confirmation_token)
      assert_redirected_to new_user_session_path
      assert user.reload.confirmed?
    end

    test 'guest should get show wrong confirmation' do
      get user_confirmation_path(confirmation_token: 'wrong_token')
      assert_response 200
      assert_select 'header h2', 'Send confirmation link again'
    end

    test 'guest should not put confirm email with wrong token' do
      put_confirm('wrong_token', 'password', 'password')
      assert_response 404
    end

    test 'guest should put confirm email for user without password' do
      put_confirm(user_without_password.confirmation_token, 'password', 'password')
      assert_redirected_to root_path
    end

    test 'guest should not put confirm email for user with password' do
      put_confirm(user.confirmation_token, 'password', 'password')
      assert_not_authorized
    end

    test 'guest should not put confirm email json' do
      put users_confirm_path,
          params: {
            email: user.email
          },
          headers: argu_headers(accept: :json)
      assert_response :forbidden
      assert_not user.reload.confirmed?
    end

    test 'guest should post create confirmation' do
      create_email_mock(
        'requested_confirmation',
        user.email,
        email: user.email,
        token_url: /.+/,
        email_only: true
      )
      post user_confirmation_path(user: {email: user.email})
      assert_equal user.primary_email_record.confirmation_sent_at.iso8601(6),
                   user.primary_email_record.reload.confirmation_sent_at.iso8601(6)
      assert_redirected_to new_user_session_path
      assert_equal flash[:notice],
                   'You\'ll receive a mail containing instructions to confirm your account within a few minutes.'
      assert_email_sent
    end

    ####################################
    # As user
    ####################################
    let(:user) { create(:unconfirmed_user) }

    test 'user without shortname should get show confirmation' do
      sign_in user
      user.shortname.destroy
      user.reload
      assert_not user.confirmed?
      assert_not user.url.present?
      get user_confirmation_path(confirmation_token: user.confirmation_token)
      assert_redirected_to new_user_session_path
      assert user.reload.confirmed?
    end

    test 'user should get show confirmation and persist temporary votes' do
      id1 = unconfirmed_vote.id
      edge1_id = unconfirmed_vote.id
      id2 = unconfirmed_vote2.id
      edge2_id = unconfirmed_vote2.id
      other_unconfirmed_vote
      other_unconfirmed_vote3

      sign_in user
      assert_not user.confirmed?
      assert_difference('Edge.where(confirmed: true).count' => 2,
                        'motion.default_vote_event.reload.children_count(:votes_pro)' => 1) do
        Sidekiq::Testing.inline! do
          get user_confirmation_path(confirmation_token: user.confirmation_token)
        end
      end

      assert_redirected_to new_user_session_path
      assert user.reload.confirmed?
      assert_equal [id1, edge1_id, id2, edge2_id],
                   [user.votes.first.id, user.votes.first.id, user.votes.second.id, user.votes.second.id]
    end

    test 'user should post create confirmation' do
      sign_in user
      create_email_mock(
        'requested_confirmation',
        user.email,
        email: user.email,
        token_url: /.+/
      )
      post user_confirmation_path(user: {email: user.email})
      assert_equal user.primary_email_record.confirmation_sent_at.iso8601(6),
                   user.primary_email_record.reload.confirmation_sent_at.iso8601(6)
      assert_redirected_to settings_path(tab: :authentication)
      assert_equal flash[:notice],
                   'You\'ll receive a mail containing instructions to confirm your account within a few minutes.'
      assert_email_sent
    end

    test 'user should not put confirm email with wrong token' do
      sign_in user
      put_confirm('wrong_token', 'password', 'password')
      assert_response 404
    end

    test 'user without password should put confirm email' do
      sign_in user_without_password
      put_confirm(user_without_password.confirmation_token, 'password', 'password')

      assert_redirected_to root_path
    end

    test 'user with password should not put confirm email' do
      sign_in user
      put_confirm(user.confirmation_token, 'password', 'password')

      put users_confirm_path,
          params: {
            user: {
              confirmation_token: user.confirmation_token,
              password: 'password',
              password_confirmation: 'password'
            }
          }
      assert_not_authorized
    end

    test 'user should not put confirm email json' do
      sign_in user
      put users_confirm_path,
          params: {
            email: user.email
          },
          headers: argu_headers(accept: :json)
      assert_response :forbidden
      assert_not user.reload.confirmed?
    end

    ####################################
    # As service
    ####################################
    test 'service should not put confirm wrong email json' do
      sign_in :service

      put users_confirm_path,
          params: {
            email: 'wrong@example.com'
          },
          headers: argu_headers(accept: :json)
      assert_response 404
      assert_not user.reload.confirmed?
    end

    test 'service should put confirm email json' do
      sign_in :service

      assert_not user.confirmed?
      put users_confirm_path,
          params: {
            email: user.email
          },
          headers: argu_headers(accept: :json)
      assert_response 200
      assert user.reload.confirmed?
    end

    private

    def put_confirm(confirmation_token, password, password_confirmation)
      put users_confirm_path,
          params: {
            user: {
              confirmation_token: confirmation_token,
              password: password,
              password_confirmation: password_confirmation
            }
          }
    end

    def user_confirmation_path(*args)
      "/#{argu.url}#{super}"
    end

    def users_confirm_path
      "/#{argu.url}#{super}"
    end
  end
end
