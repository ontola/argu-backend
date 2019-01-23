# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Dropdown', type: :feature do
  # Names need be different since header_helper#public_forum_items checks for those names
  define_freetown('nederland', attributes: {name: 'nederland'})
  define_freetown('houten', attributes: {name: 'houten'})

  scenario 'User switches forum with forum dropdown' do
    Setting.set('suggested_forums', [nederland.uuid, houten.uuid].join(','))
    visit resource_iri(nederland)

    within('.navbar-forum-selector') do
      find('.navbar-forums').click
      click_link houten.name
    end

    expect(page).to have_content houten.display_name
    expect(page).to have_current_path resource_iri(houten)
  end

  # scenario 'Dropdown still works after navigating back and forth' do
  #   visit holland.iri.path
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
  #   expect(page).to have_current_path holland.iri.path
  #
  #   page.driver.go_back
  #   expect(page).to have_content other.display_name
  #   expect(page).to have_current_path forum_path(other)
  #   page.driver.go_back
  #   expect(page).to have_content holland.display_name
  #   expect(current_path).to eq holland.iri.path
  #
  #   within('.cover-switcher') do
  #     find('.dropdown-trigger').hover
  #     click_link other.name
  #   end
  #   expect(page).to have_content other.display_name
  #   expect(current_path).to eq forum_path(other)
  # end
end
