require 'rails_helper'

RSpec.feature 'Dropdown', type: :feature do
  # Names need be different since header_helper#public_forum_items checks for those names
  define_common_objects :freetown,
                        forum!: {var_name: :other, name: 'houten'}

  scenario 'User switches forum with forum dropdown' do
    visit forum_path(freetown)

    within('.navbar-forum-selector') do
      click_on 'Forums'
      click_link other.name
    end

    expect(page).to have_content other.display_name
    expect(page).to have_current_path forum_path(other)
  end

  # scenario 'Dropdown still works after navigating back and forth' do
  #   visit forum_path(holland)
  #
  #   within('.cover-switcher') do
  #     find('.dropdown-trigger').hover
  #     click_link other.name
  #   end
  #   expect(page).to have_current_path forum_path(other)
  #   expect(page).to have_content other.display_name
  #
  #   within('.cover-switcher') do
  #     find('.dropdown-trigger').hover
  #     click_link holland.name
  #   end
  #   expect(page).to have_content holland.display_name
  #   expect(page).to have_current_path forum_path(holland)
  #
  #   page.driver.go_back
  #   expect(page).to have_content other.display_name
  #   expect(page).to have_current_path forum_path(other)
  #   page.driver.go_back
  #   expect(page).to have_content holland.display_name
  #   expect(current_path).to eq forum_path(holland)
  #
  #   within('.cover-switcher') do
  #     find('.dropdown-trigger').hover
  #     click_link other.name
  #   end
  #   expect(page).to have_content other.display_name
  #   expect(current_path).to eq forum_path(other)
  # end
end
