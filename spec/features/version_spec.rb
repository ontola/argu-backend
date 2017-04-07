# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Version', type: :feature do
  define_freetown

  scenario 'should reload page on version change' do
    visit discover_forums_path

    page.execute_script('window.arguVersion = "0.0.1";')

    page.dismiss_confirm 'A new version of Argu has been released. Would you like to reload this page? (recommended)' do
      click_link('Show open forums')
    end

    page.accept_confirm 'A new version of Argu has been released. Would you like to reload this page? (recommended)' do
      click_link('Show open forums')
    end

    click_link('Show open forums')
    expect(page).to have_current_path discover_forums_path
  end
end
