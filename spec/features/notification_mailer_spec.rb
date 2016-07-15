# frozen_string_literal: true
require 'rails_helper'
include MailerHelper

RSpec.feature 'Notification mailer' do
  define_freetown
  let!(:motion) { create(:motion, parent: freetown.edge) }
  let!(:argument) { create(:argument, parent: motion.edge) }
  let!(:comment) { create(:comment, parent: argument.edge) }

  let!(:follow) do
    create(:follow,
           :t_argument,
           followable: argument.edge,
           follower: follower)
  end

  let!(:follower) { create :user, :viewed_notifications_hour_ago, :follows_reactions_directly }

  let(:argument_notification) do
    create(:notification,
           activity: argument.activities.first,
           user: follower)
  end

  let(:comment_notification) do
    create(:notification,
           activity: comment.activities.first,
           user: follower)
  end

  background do
    clear_emails
  end

  scenario 'Send mail with one notification' do
    email_type = User.reactions_emails[:direct_reactions_email]
    argument_notification

    Sidekiq::Testing.inline! do
      SendNotificationsWorker.perform_async(follower.id, email_type)
    end
    open_email(follower.email)

    expect(current_email.subject).to eq notification_subject(argument_notification)
    expect(current_email).to have_content argument_notification.activity.trackable.content

    current_email.click_link 'Go to discussion'
    expect(page).to have_current_path argument_path(argument_notification.activity.trackable)
  end

  scenario 'Send mail with two notifications' do
    email_type = User.reactions_emails[:direct_reactions_email]
    argument_notification
    comment_notification

    Sidekiq::Testing.inline! do
      SendNotificationsWorker.perform_async(follower.id, email_type)
    end
    open_email(follower.email)

    expect(current_email.subject).to eq 'New Argu notifications'
    expect(current_email).to have_content argument_notification.activity.trackable.content
    expect(current_email).to have_content comment_notification.activity.trackable.body
  end
end
