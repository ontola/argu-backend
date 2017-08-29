# frozen_string_literal: true
require 'test_helper'

class FeedTest < ActionDispatch::IntegrationTest
  define_freetown
  let(:subject) { create(:motion, :with_votes, parent: freetown.edge, creator: publisher.profile) }
  let(:unpublished_motion) do
    create(:motion, parent: freetown.edge, edge_attributes: {argu_publication_attributes: {draft: true}})
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

    # Only render activity of Motion#publish
    assert_select '.activity-feed .activity', 1
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

  test 'staff should get additional activities for motion/feed' do
    sign_in staff

    get motion_feed_path(subject), params: {format: :js, from_time: 1.hour.from_now, complete: false}

    assert_response 200
  end

  test 'staff should get additional activities for user/feed' do
    sign_in staff
    subject

    get user_feed_path(publisher), params: {format: :js, from_time: 1.hour.from_now, complete: false}

    assert_response 200
  end

  test 'staff should get additional activities for favorites/feed' do
    sign_in staff
    create(:favorite, edge: freetown.edge, user: staff)
    subject

    get feed_path, params: {format: :js, from_time: 1.hour.from_now, complete: false}

    assert_response 200
  end

  private

  # Render activity of Motion#create, Motion#publish, 6 public votes and 2 private votes
  def assert_activity_count(format: :html, staff: false)
    count = staff ? 10 : 7
    case format
    when :html
      assert_select '.activity-feed .activity', count
    when :json
      assert_equal parsed_body['data'].count, count
    end
  end
end
