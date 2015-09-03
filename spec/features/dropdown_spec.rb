require 'rails_helper'

RSpec.feature 'Login', type: :feature do

  # Names need be different since header_helper#public_forum_items checks for those names
  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'nederland') }
  let!(:other) { FactoryGirl.create(:populated_forum, name: 'houten') }

  scenario 'User switches forum with forum dropdown' do
    visit forum_path(holland)

    within('.navbar-forum-selector') do
      click_on 'Forums'
      click_link other.name
    end

    expect(page).to have_content other.display_name
    expect(current_path).to eq forum_path(other)
  end
end
