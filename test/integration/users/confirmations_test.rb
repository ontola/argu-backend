# frozen_string_literal: true
require 'test_helper'

module Users
  class ConfirmationsTest < ActionDispatch::IntegrationTest
    define_freetown
    let(:user) { create(:user, :unconfirmed) }
    let(:other_user) { create(:user, :unconfirmed) }
    let(:confirmed_user) { create(:user) }
    let(:motion) { create(:motion, parent: freetown.edge) }
    let(:motion2) { create(:motion, parent: freetown.edge) }
    let(:motion3) { create(:motion, parent: freetown.edge) }
    let(:confirmed_vote) do
      create(:vote, parent: motion.default_vote_event.edge, creator: confirmed_user.profile, publisher: confirmed_user)
    end
    let(:unconfirmed_vote) do
      create(:vote, parent: motion.default_vote_event.edge, creator: user.profile, publisher: user)
    end
    let(:unconfirmed_vote2) do
      create(:vote, parent: motion2.default_vote_event.edge, creator: user.profile, publisher: user)
    end
    let(:other_unconfirmed_vote) do
      create(:vote, parent: motion.default_vote_event.edge, creator: other_user.profile, publisher: other_user)
    end
    let(:other_unconfirmed_vote3) do
      create(:vote, parent: motion3.default_vote_event.edge, creator: other_user.profile, publisher: other_user)
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

    ####################################
    # As user
    ####################################
    let(:user) { create(:user, :unconfirmed) }

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

    test 'user without finished intro should get show confirmation' do
      sign_in user
      user.update(finished_intro: false)
      user.reload
      assert_not user.confirmed?
      assert_not user.finished_intro?
      get user_confirmation_path(confirmation_token: user.confirmation_token)
      assert_redirected_to new_user_session_path
      assert user.reload.confirmed?
    end

    test 'user should get show confirmation and persist temporary votes' do
      id1 = unconfirmed_vote.id
      edge1_id = unconfirmed_vote.edge.id
      id2 = unconfirmed_vote2.id
      edge2_id = unconfirmed_vote2.edge.id
      other_unconfirmed_vote
      other_unconfirmed_vote3

      sign_in user
      assert_not user.confirmed?
      assert_difference('Vote.count', 2) do
        Sidekiq::Testing.inline! do
          get user_confirmation_path(confirmation_token: user.confirmation_token)
        end
      end
      assert_redirected_to new_user_session_path
      assert user.reload.confirmed?
      assert_equal [id1, edge1_id, id2, edge2_id],
                   [user.votes.first.id, user.votes.first.edge.id, user.votes.second.id, user.votes.second.edge.id]
    end

    test 'user should get show confirmation and persist temporary votes except if already present in postgres' do
      unconfirmed_vote.id
      unconfirmed_vote.edge.id
      id2 = unconfirmed_vote2.id
      edge2_id = unconfirmed_vote2.edge.id
      other_unconfirmed_vote
      other_unconfirmed_vote3
      confirmed_vote.update(publisher_id: user.id, creator_id: user.profile.id)
      confirmed_vote.edge.update(user_id: user.id)

      sign_in user
      assert_not user.confirmed?
      assert_difference('Vote.count', 1) do
        Sidekiq::Testing.inline! do
          get user_confirmation_path(confirmation_token: user.confirmation_token)
        end
      end
      assert_redirected_to new_user_session_path
      assert user.reload.confirmed?
      assert_equal [id2, edge2_id, confirmed_vote.id, confirmed_vote.edge.id],
                   [user.votes.first.id, user.votes.first.edge.id, user.votes.second.id, user.votes.second.edge.id]
    end

    test 'user should post create confirmation' do
      sign_in user
      post user_confirmation_path(user: {email: user.email})
      assert_not_equal user.primary_email_record.confirmation_sent_at.iso8601(6),
                       user.primary_email_record.reload.confirmation_sent_at.iso8601(6)
      assert_redirected_to settings_path(tab: :authentication)
    end
  end
end
