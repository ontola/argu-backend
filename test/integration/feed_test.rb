# frozen_string_literal: true
require 'test_helper'

class FeedTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:subject) { create(:motion, :with_votes, parent: freetown.edge) }
  let(:unpublished_motion) do
    create(:motion, parent: freetown.edge, edge_attributes: {argu_publication_attributes: {publish_type: 'draft'}})
  end
  let(:publisher) { create(:user) }
  let(:trashed_motion) do
    m = create(:motion, parent: freetown.edge)
    TrashService.new(m, options: {creator: publisher.profile, publisher: publisher}).commit
    m
  end

  ####################################
  # As Guest
  ####################################

  test 'guest should get motion/feed json' do
    get motion_feed_path(subject),
        params: {format: :json}

    assert_response 200

    assert_activity_count(format: :json)
  end

  test 'guest should get motion/feed html' do
    get motion_feed_path(subject)

    assert_response 200

    assert_activity_count
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get forum/feed' do
    sign_in user
    unpublished_motion
    trashed_motion

    get forum_feed_path(freetown)

    assert_response 200

    assert_select '.activity-feed'

    # Render activity of Motion#create, Motion#publish and Motion#trash
    assert_select '.activity-feed .activity', 3
  end

  test 'user should get motion/feed' do
    sign_in user

    get motion_feed_path(subject),
        params: {format: :json}

    assert_response 200

    assert_activity_count(format: :json)
  end

  test 'user should get motion/feed html' do
    sign_in user

    get motion_feed_path(subject)

    assert_response 200

    assert_activity_count
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  test 'staff should get motion/feed' do
    sign_in staff

    get motion_feed_path(subject),
        params: {format: :json}

    assert_response 200

    assert_activity_count(format: :json, staff: true)
  end

  test 'staff should get motion/feed html' do
    sign_in staff

    get motion_feed_path(subject)

    assert_response 200

    assert_activity_count(staff: true)
  end

  private

  # Render activity of Motion#create, Motion#publish, 6 public votes and 2 private votes
  def assert_activity_count(format: :html, staff: false)
    count = staff ? 10 : 8
    case format
    when :html
      assert_select '.activity-feed .activity', count
    when :json
      assert_equal parsed_body['data'].count, count
    end
  end
end
