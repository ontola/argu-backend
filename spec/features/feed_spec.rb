# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Feed', type: :feature do
  define_freetown
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown) }
  let(:user) { create(:user) }
  let(:user_motions) { 8.times { create(:motion, parent: freetown, publisher: user) } }
  let(:user_questions) { 8.times { create(:question, parent: freetown, publisher: user) } }

  scenario 'Guest views feed of forum' do
    motion
    # 1x Motion#create, 1x Motion#publish, 6x Argument#create, 6x Argument#publish, 2x Argument#trash,
    # 3x Vote#create, 3x HiddenVote#create, 6x Comment#create, 6x Comment#publish
    expect(Activity.count).to eq(34)
    Activity.order(:created_at).each_with_index do |activity, i|
      activity.update(created_at: i.minutes.ago)
    end
    visit(feeds_iri(freetown))
    page.find('.btn.load-more').click
    expect(page).to have_selector('.activity-feed .activity', count: 13)
  end

  scenario 'Guest views feed of user' do
    user_motions
    user_questions
    # 8x Motion#publish, 8x Question#publish,
    expect(Activity.count).to eq(32)
    Activity.order(:created_at).each_with_index do |activity, i|
      activity.update(created_at: i.minutes.ago)
    end
    visit(user_path(user))
    page.find('.btn.load-more').click
    expect(page).to have_selector('.activity-feed .activity', count: 10)
    page.find('.btn.load-more').click
    expect(page).to have_selector('.activity-feed .activity', count: 16)
  end
end
