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
    test 'guest should not delete destroy follows' do
      assert_difference(no_differences) do
        delete collection_iri(user, :follows, root: argu)
      end
      assert_not_a_user
    end

    ####################################
    # As user
    ####################################
    test 'other_user should not delete destroy follows' do
      sign_in other_user
      assert_difference(no_differences) do
        delete collection_iri(user, :follows, root: argu)
      end
      assert_not_authorized
    end

    test 'user should delete destroy follows' do
      sign_in user
      assert_difference(unsubscribe_differences) do
        delete collection_iri(user, :follows, root: argu)
      end
      assert_response :success
      expect_ontola_action(snackbar: 'Notifications deleted successfully')
    end

    test 'user should post destroy follows' do
      sign_in user
      assert_difference('Follow.news.count' => -1) do
        post news_follow.iri
      end
      assert_response :success
      expect_ontola_action(snackbar: "You no longer receive notifications for '#{motion.display_name}'")
    end

    private

    def no_differences
      {
        'Follow.news.count' => 0,
        'Follow.reactions.count' => 0,
        'Follow.never.count' => 0
      }
    end

    def unsubscribe_differences
      {
        'Follow.news.count' => -1,
        'Follow.reactions.count' => -1,
        'Follow.never.count' => 2
      }
    end
  end
end
