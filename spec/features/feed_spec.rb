# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Feed', type: :feature do
  define_freetown
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown.edge) }
  let(:user) { create(:user) }
  let(:user_motion) { create(:motion, parent: freetown.edge, publisher: user) }
  let(:user_question) { create(:question, parent: freetown.edge, publisher: user) }

  scenario 'Guest views feed of forum' do
    motion
    # 1x Motion#create, 1x Motion#publish, 6x Argument#create, 2x Argument#trash, 6x Vote#create, 3x HiddenVote#create
    expect(Activity.count).to eq(19)
    Activity.order(:created_at).each_with_index do |activity, i|
      activity.update(created_at: i.minutes.ago)
    end
    visit(forum_feed_path(freetown))
    expect(page).to have_selector('.activity-feed .activity', count: 10)
    page.find('.btn.load-more').click
    expect(page).to have_selector('.activity-feed .activity', count: 16)
  end

  scenario 'Guest views feed of user' do
    user_motion
    user_question
    # 1x Motion#create, 1x Motion#publish, 1x Question#create, 1x Question#publish,
    expect(Activity.count).to eq(4)
    Activity.order(:created_at).each_with_index do |activity, i|
      activity.update(created_at: i.minutes.ago)
    end
    visit(user_path(user))
    expect(page).to have_selector('.activity-feed .activity', count: 4)
  end
end
