# frozen_string_literal: true

require 'test_helper'

class ActivityNotificationsReceiversCollectorTest < ActiveSupport::TestCase
  define_freetown
  let(:publisher) { create(:user, :follows_reactions_never, :follows_news_never) }
  let(:question) { create(:question, parent: freetown, publisher: publisher) }
  let(:argument) do
    create(:argument,
           publisher: publisher,
           parent: create(:motion, parent: freetown, publisher: publisher))
  end
  let(:blog_post) do
    create(:blog_post,
           publisher: publisher,
           parent: question)
  end

  test 'should collect direct followers for notifications' do
    Follow.destroy_all
    # should be collected for direct mailing
    follow_and_notification_pair(blog_post, :follows_reactions_directly, :follows_news_directly)
    follow_and_notification_pair(argument, :follows_reactions_directly, :follows_news_directly)
    follow_and_notification_pair(blog_post, :follows_reactions_weekly, :follows_news_directly)
    follow_and_notification_pair(argument, :follows_reactions_directly, :follows_news_weekly)
    # should be collected for weekly mailing
    follow_and_notification_pair(blog_post, :follows_reactions_weekly, :follows_news_weekly)
    follow_and_notification_pair(argument, :follows_reactions_weekly, :follows_news_weekly)
    follow_and_notification_pair(blog_post, :follows_reactions_directly, :follows_news_weekly)
    follow_and_notification_pair(argument, :follows_reactions_weekly, :follows_news_directly)
    follow_and_notification_pair(argument, :follows_reactions_directly, :follows_news_weekly, :not_accepted_terms)

    direct_user_ids = ActivityNotificationsReceiversCollector.new(User.reactions_emails[:direct_reactions_email]).call
    assert_equal 4, direct_user_ids.count
    weekly_user_ids = ActivityNotificationsReceiversCollector.new(User.reactions_emails[:weekly_reactions_email]).call
    assert_equal 4, weekly_user_ids.count
    assert_equal [], direct_user_ids & weekly_user_ids
  end

  test 'should not collect followers that have been mailed already' do
    follow_and_notification_pair(
      blog_post,
      :follows_reactions_weekly,
      :follows_news_weekly,
      :viewed_notifications_now
    )
    follow_and_notification_pair(
      argument,
      :follows_reactions_weekly,
      :follows_news_weekly,
      :viewed_notifications_now
    )

    user_ids = ActivityNotificationsReceiversCollector.new(User.reactions_emails[:weekly_reactions_email]).call
    assert_equal 0, user_ids.count
  end

  private

  def follow_and_notification_pair(trackable, *traits)
    traits.append(:viewed_notifications_hour_ago) if traits.none? { |t| t.to_s.include?('viewed_notifications') }
    user = create(:user, *(traits - [:not_accepted_terms]))
    create(:follow,
           followable: trackable,
           follower: user)

    create(:notification,
           activity: trackable.activities.first,
           user: user,
           created_at: 30.minutes.ago)

    create(:notification,
           activity: trackable.activities.first,
           user: user,
           created_at: 1.day.ago)

    user.update!(last_accepted: nil) if traits.include?(:not_accepted_terms)
  end
end
