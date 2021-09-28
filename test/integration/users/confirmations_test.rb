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
    test 'guest without token should get show confirmation' do
      assert_not user.confirmed?
      get user_confirmation_path(confirmation_token: user.confirmation_token), headers: argu_headers
      assert_response :success
      assert_not response.headers['New-Authorization']
      assert_not user.reload.confirmed?
    end

    test 'guest should get show confirmation' do
      sign_in :guest_user
      assert_not user.confirmed?
      get user_confirmation_path(confirmation_token: user.confirmation_token)
      assert_response :success
      assert_not user.reload.confirmed?
    end

    test 'guest should not get show confirmation of confirmed user' do
      sign_in :guest_user
      assert confirmed_user.confirmed?
      get user_confirmation_path(confirmation_token: confirmed_user.confirmation_token)
      assert_response :success
      assert_not response.headers['New-Authorization']
      assert_not user.reload.confirmed?
    end

    test 'guest should get show wrong confirmation' do
      sign_in :guest_user
      get user_confirmation_path(confirmation_token: 'wrong_token')
      assert_response 404
    end

    test 'guest should put update confirmation' do
      sign_in :guest_user
      assert_not user.confirmed?
      put user_confirmation_path(confirmation_token: user.confirmation_token)
      assert_response :success
      assert response.headers['New-Authorization']
      assert user.reload.confirmed?
    end

    test 'guest should not put update confirmation of confirmed user' do
      sign_in :guest_user
      assert confirmed_user.confirmed?
      put user_confirmation_path(confirmation_token: confirmed_user.confirmation_token)
      assert_response :success
      assert_not response.headers['New-Authorization']
      expect_ontola_action(
        redirect: '/argu',
        snackbar: 'Email was already confirmed, try to log in.'
      )
    end

    test 'guest should put update wrong confirmation' do
      sign_in :guest_user
      put user_confirmation_path(confirmation_token: 'wrong_token')
      assert_response 404
    end

    test 'guest should not put confirm email json' do
      sign_in :guest_user
      put user_confirmation_path,
          params: {
            email: user.email
          },
          headers: argu_headers(accept: :json)
      assert_response :not_found
      assert_not user.reload.confirmed?
    end

    test 'guest should get new confirmation' do
      sign_in :guest_user
      get new_user_confirmation_path
      assert_enabled_form
    end

    test 'guest should post create confirmation' do
      sign_in :guest_user
      create_email_mock(
        'requested_confirmation',
        user.email,
        email: user.email,
        token_url: /.+/,
        email_only: true
      )
      post user_confirmation_path,
           params: {user: {email: user.email}}
      assert_equal user.primary_email_record.confirmation_sent_at.iso8601(6),
                   user.primary_email_record.reload.confirmation_sent_at.iso8601(6)
      assert_response :created
      expect_ontola_action(
        snackbar: 'You\'ll receive a mail containing instructions to confirm your account within a few minutes.'
      )
      assert_email_sent
    end

    ####################################
    # As other user
    ####################################
    test 'other_user should get show confirmation' do
      sign_in other_user
      assert_not user.confirmed?
      get user_confirmation_path(confirmation_token: user.confirmation_token)
      assert_response :success
      assert_not response.headers['New-Authorization']
      assert_not user.reload.confirmed?
    end

    test 'other_user should not get show confirmation of confirmed user' do
      sign_in other_user
      assert confirmed_user.confirmed?
      get user_confirmation_path(confirmation_token: confirmed_user.confirmation_token)
      assert_response :success
      assert_not response.headers['New-Authorization']
    end

    test 'other_user should put update confirmation' do
      sign_in other_user
      assert_not user.confirmed?
      put user_confirmation_path(confirmation_token: user.confirmation_token)
      assert_response :success
      assert response.headers['New-Authorization']
      assert user.reload.confirmed?
    end

    test 'other_user should not put update confirmation of confirmed user' do
      sign_in other_user
      assert confirmed_user.confirmed?
      put user_confirmation_path(confirmation_token: confirmed_user.confirmation_token)
      assert_response :success
      assert_not response.headers['New-Authorization']
      assert confirmed_user.reload.confirmed?
      expect_ontola_action(
        redirect: '/argu',
        snackbar: 'Email was already confirmed, try to log in.'
      )
    end

    test 'other_user should not post create confirmation' do
      sign_in other_user
      post user_confirmation_path,
           params: {user: {email: user.email}}
      assert_response :not_found
    end

    ####################################
    # As user
    ####################################
    let(:user) { create(:unconfirmed_user) }

    test 'user should get show confirmation' do
      sign_in user
      get user_confirmation_path(confirmation_token: user.confirmation_token)
      assert_response :success
      assert_not user.reload.confirmed?
      assert_not response.headers['New-Authorization']
    end

    test 'user should put update confirmation and persist temporary votes' do
      id1 = unconfirmed_vote.id
      edge1_id = unconfirmed_vote.id
      id2 = unconfirmed_vote2.id
      edge2_id = unconfirmed_vote2.id
      other_unconfirmed_vote
      other_unconfirmed_vote3

      sign_in user
      assert_not user.confirmed?
      assert_difference('Edge.where(confirmed: true).count' => 2,
                        'motion.default_vote_event.reload.pro_count' => 1) do
        Sidekiq::Testing.inline! do
          put user_confirmation_path(confirmation_token: user.confirmation_token)
        end
      end

      assert_response :success
      expect_ontola_action(
        snackbar: 'Your account has been confirmed',
        redirect: '/argu'
      )
      assert user.reload.confirmed?
      assert_equal [id1, edge1_id, id2, edge2_id],
                   [user.votes.first.id, user.votes.first.id, user.votes.second.id, user.votes.second.id]
    end

    test 'user should not put confirm email json' do
      sign_in user
      put user_confirmation_path,
          params: {
            email: user.email
          },
          headers: argu_headers(accept: :json)
      assert_response :not_found
      assert_not user.reload.confirmed?
    end

    test 'user should get new confirmation' do
      sign_in user
      get new_user_confirmation_path
      assert_enabled_form
    end

    test 'user should post create confirmation' do
      sign_in user
      create_email_mock(
        'requested_confirmation',
        user.email,
        email: user.email,
        token_url: /.+/
      )
      post user_confirmation_path,
           params: {user: {email: user.email}}
      assert_equal user.primary_email_record.confirmation_sent_at.iso8601(6),
                   user.primary_email_record.reload.confirmation_sent_at.iso8601(6)
      expect_ontola_action(
        snackbar: 'You\'ll receive a mail containing instructions to confirm your account within a few minutes.'
      )
      assert_email_sent
    end

    ####################################
    # As service
    ####################################
    test 'service should not put confirm wrong email json' do
      sign_in :service

      put user_confirmation_path,
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
      put user_confirmation_path,
          params: {
            email: user.email
          },
          headers: argu_headers(accept: :json)
      assert_response :success
      assert user.reload.confirmed?
    end

    private

    def user_confirmation_path(params = nil)
      ["/#{argu.url}/u/confirmation", params&.to_param].compact.join('?')
    end

    def new_user_confirmation_path
      "/#{argu.url}/u/confirmation/new"
    end
  end
end
