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
           parent: motion)
  end

  ####################################
  # As guest
  ####################################
  test 'guest should get index' do
    argument
    sign_in :guest_user
    get collection_iri(argu, :notifications)
    assert_response 401
  end

  test 'guest should not mark as read' do
    argument
    sign_in :guest_user
    assert_difference('Notification.count' => 0, 'Notification.where(read_at: nil).count' => 0) do
      patch "#{collection_iri(argu, :notifications)}/read"
      assert_response 401
    end
  end

  ####################################
  # As follower
  ####################################
  let(:follower) { motion.publisher }

  test 'follower should get index as nq' do
    argument
    sign_in follower
    get collection_iri(argu, :notifications), headers: argu_headers(accept: :nq)
    assert_response 200
    expect_triple(RDF::URI("#{argu.iri}/n"), NS::ARGU[:unreadCount], 1)
  end

  test 'follower should put update as nq' do
    argument
    sign_in follower
    notification = follower.notifications.where(read_at: nil).first
    assert_difference('Notification.count' => 0, 'Notification.where(read_at: nil).count' => -1) do
      put resource_iri(notification), headers: argu_headers(accept: :nq)
    end
    assert_response 200
    notification.reload
    expect_triple(RDF::URI("#{argu.iri}/n"), NS::ARGU[:unreadCount], 0)
    expect_triple(
      resource_iri(notification),
      NS::SCHEMA[:dateRead],
      notification.read_at.to_datetime,
      NS::ONTOLA[:replace]
    )
    expect_triple(resource_iri(notification), NS::ARGU[:unread], false, NS::ONTOLA[:replace])
  end
end
