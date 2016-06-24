require 'test_helper'

class MailReceiversCollectorTest < ActiveSupport::TestCase
  let(:freetown) { create(:forum) }
  let(:publisher) { create(:user, :follows_reactions_never, :follows_news_never) }
  let(:project) { create(:project, forum: freetown, publisher: publisher) }
  let(:argument) do
    create(:argument,
           forum: freetown,
           publisher: publisher,
           motion: create(:motion, forum: freetown, publisher: publisher))
  end
  let(:blog_post) do
    create(:blog_post, publisher: publisher, happened_at: DateTime.current, blog_postable: project, forum: freetown)
  end

  test 'should collect direct followers for notifications' do
    # should be collected for direct mailing
    create_follow_and_notification_pair(blog_post, :follows_reactions_directly, :follows_news_directly)
    create_follow_and_notification_pair(argument, :follows_reactions_directly, :follows_news_directly)
    create_follow_and_notification_pair(blog_post, :follows_reactions_weekly, :follows_news_directly)
    create_follow_and_notification_pair(argument, :follows_reactions_directly, :follows_news_weekly)
    # should be collected for weekly mailing
    create_follow_and_notification_pair(blog_post, :follows_reactions_weekly, :follows_news_weekly)
    create_follow_and_notification_pair(argument, :follows_reactions_weekly, :follows_news_weekly)
    create_follow_and_notification_pair(blog_post, :follows_reactions_directly, :follows_news_weekly)
    create_follow_and_notification_pair(argument, :follows_reactions_weekly, :follows_news_directly)

    direct_user_ids = MailReceiversCollector.new(User.reactions_emails[:direct_reactions_email]).call
    assert_equal 4, direct_user_ids.count
    weekly_user_ids = MailReceiversCollector.new(User.reactions_emails[:weekly_reactions_email]).call
    assert_equal 4, weekly_user_ids.count
    assert_equal [], direct_user_ids & weekly_user_ids
  end

  test 'should not collect followers that has been mailed already' do
    create_follow_and_notification_pair(
      blog_post,
      :follows_reactions_weekly,
      :follows_news_weekly,
      :viewed_notifications_now)
    create_follow_and_notification_pair(
      argument,
      :follows_reactions_weekly,
      :follows_news_weekly,
      :viewed_notifications_now)

    user_ids = MailReceiversCollector.new(User.reactions_emails[:weekly_reactions_email]).call
    assert_equal 0, user_ids.count
  end

  private

  def create_follow_and_notification_pair(trackable, reactions, news, viewed = :viewed_notifications_hour_ago)
    user = create(:user, reactions, news, viewed)
    create(:follow,
           followable: trackable.edge,
           follower: user)

    create(:notification,
           activity: trackable.activities.first,
           user: user,
           created_at: 10.minutes.ago)

    create(:notification,
           activity: trackable.activities.first,
           user: user,
           created_at: 1.day.ago)
  end
end
