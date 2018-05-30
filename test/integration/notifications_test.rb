# frozen_string_literal: true

require 'test_helper'

class NotificationsTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:user) { create(:user) }
  let(:question) { create(:question, :with_follower, :with_news_follower, parent: freetown) }
  let(:motion) { create(:motion, :with_follower, :with_news_follower, parent: question) }
  let(:argument) { create(:argument, :with_follower, :with_news_follower, parent: motion) }
  let(:comment) { create(:comment, parent: argument) }
  let(:group) { create(:group, parent: argu) }
  let(:group_membership) { create(:group_membership, parent: group, member: user.profile) }
  let!(:random_follow) { create(:follow, followable: create_forum) }
  let(:blog_post) do
    create(:blog_post,
           :with_follower,
           :with_news_follower,
           happening_attributes: {happened_at: Time.current},
           parent: motion)
  end

  ####################################
  # As guest
  ####################################
  test 'guest should get index' do
    argument
    get notifications_path, headers: argu_headers(accept: :json)
    assert_response 401
  end

  test 'guest should not mark as read' do
    argument
    assert_differences([['Notification.count', 0], ['Notification.where(read_at: nil).count', 0]]) do
      patch read_notifications_path
      assert_response 302
    end
  end

  ####################################
  # As follower
  ####################################
  let(:follower) { motion.publisher }

  test 'follower should get index' do
    argument
    sign_in follower
    get notifications_path, headers: argu_headers(accept: :json)
    assert_response 200
    assert_equal parsed_body['notifications']['unread'], 1
  end

  test 'follower should get index as nt' do
    argument
    sign_in follower
    get notifications_path, headers: argu_headers(accept: :nt)
    assert_response 200
    assert_includes response.body,
                    [
                      "<#{argu_url('/n', type: :paginated)}>",
                      '<https://argu.co/ns/core#unreadCount>',
                      '"1"^^<http://www.w3.org/2001/XMLSchema#integer> .'
                    ].join(' ')
  end

  test 'follower should mark as read' do
    argument
    sign_in follower
    assert_differences([['Notification.count', 0], ['Notification.where(read_at: nil).count', -1]]) do
      patch read_notifications_path, headers: argu_headers(accept: :json)
      assert_response 200
    end
  end
end
