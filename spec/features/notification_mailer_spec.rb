require 'rails_helper'
include MailerHelper

RSpec.feature 'Notification mailer' do
  let(:activity_argument) do
    create(:activity,
           :t_argument,
           trackable: argument,
           forum: argument.forum)
  end

  let(:activity_comment) do
    create(:activity,
           :t_comment,
           trackable: comment,
           forum: argument.forum)
  end

  let!(:argument) { create(:argument) }

  let!(:comment) do
    create(:comment,
           commentable: argument)
  end

  let!(:follow) do
    create(:follow,
           :t_argument,
           followable: argument,
           follower: follower)
  end

  let!(:follower) { create :user, :viewed_notifications_hour_ago, :follows_email }

  let(:notification_argument) do
    create(:notification,
           activity: activity_argument,
           user: follower)
  end

  let(:notification_comment) do
    create(:notification,
           activity: activity_comment,
           user: follower)
  end

  background do
    clear_emails
  end

  scenario 'Send mail with one notification' do
    login_as(follower)
    email_type = User.follows_emails[:direct_follows_email]
    notification_argument

    Sidekiq::Testing.inline! do
      SendNotificationsWorker.perform_async(follower.id, email_type)
    end
    open_email(follower.email)

    expect(current_email.subject).to eq notification_subject(notification_argument)
    expect(current_email).to have_content notification_argument.activity.trackable.content

    current_email.click_link 'Go to discussion'
    expect(current_path).to eq argument_path(notification_argument.activity.trackable)
  end

  scenario 'Send mail with two notifications' do
    login_as(follower)
    email_type = User.follows_emails[:direct_follows_email]
    notification_argument
    notification_comment

    Sidekiq::Testing.inline! do
      SendNotificationsWorker.perform_async(follower.id, email_type)
    end
    open_email(follower.email)

    expect(current_email.subject).to eq 'New Argu notifications'
    expect(current_email).to have_content notification_argument.activity.trackable.content
    expect(current_email).to have_content notification_comment.activity.trackable.body

    current_email.click_link notification_argument.activity.trackable.title
    expect(current_path).to eq argument_path(notification_argument.activity.trackable)
  end
end
