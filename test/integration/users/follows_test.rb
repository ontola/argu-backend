# frozen_string_literal: true

require 'test_helper'

module Users
  class FollowsTest < ActionDispatch::IntegrationTest
    define_freetown
    let(:motion) { create(:motion, parent: freetown) }
    let(:second_motion) { create(:motion, parent: freetown) }
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:news_follow) { create(:news_follow, followable: motion, follower: user) }
    let!(:follows) do
      create(:news_follow, followable: motion, follower: other_user)
      news_follow
      create(:follow, followable: second_motion, follower: user)
      create(:never_follow, followable: freetown, follower: user)
    end

    ####################################
    # As guest
    ####################################
    test 'guest should delete destroy follow' do
      sign_in :guest_user
      assert_difference('Follow.news.count' => -1) do
        delete news_follow.iri, headers: argu_headers
      end
      assert_response :success
      expect_ontola_action(
        redirect: motion.iri,
        snackbar: "You no longer receive notifications for '#{motion.display_name}'"
      )
    end

    test 'guest should post destroy follow' do
      sign_in :guest_user
      assert_difference('Follow.news.count' => -1) do
        post news_follow.iri, headers: argu_headers
      end
      assert_response :success
      expect_ontola_action(
        redirect: motion.iri,
        snackbar: "You no longer receive notifications for '#{motion.display_name}'"
      )
    end

    test 'guest should get unsubscribe follow' do
      sign_in :guest_user
      assert_difference('Follow.news.count' => -1) do
        get "#{news_follow.iri}/unsubscribe", headers: argu_headers
      end
      assert_response :success
      expect_ontola_action(
        redirect: motion.iri,
        snackbar: "You no longer receive notifications for '#{motion.display_name}'"
      )
    end

    ####################################
    # As user
    ####################################
    test 'user should delete destroy follow' do
      sign_in user
      assert_difference('Follow.news.count' => -1) do
        delete news_follow.iri, headers: argu_headers
      end
      assert_response :success
      expect_ontola_action(
        redirect: motion.iri,
        snackbar: "You no longer receive notifications for '#{motion.display_name}'"
      )
    end

    test 'user should post destroy follow' do
      sign_in user
      assert_difference('Follow.news.count' => -1) do
        post news_follow.iri, headers: argu_headers
      end
      assert_response :success
      expect_ontola_action(
        redirect: motion.iri,
        snackbar: "You no longer receive notifications for '#{motion.display_name}'"
      )
    end

    test 'user should get unsubscribe follow' do
      sign_in user
      assert_difference('Follow.news.count' => -1) do
        get "#{news_follow.iri}/unsubscribe", headers: argu_headers
      end
      assert_response :success
      expect_ontola_action(
        redirect: motion.iri,
        snackbar: "You no longer receive notifications for '#{motion.display_name}'"
      )
    end

    private

    def no_differences
      {
        'Follow.news.count' => 0,
        'Follow.reactions.count' => 0,
        'Follow.never.count' => 0
      }
    end
  end
end
