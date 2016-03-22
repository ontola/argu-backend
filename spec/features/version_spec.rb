require 'rails_helper'

RSpec.feature 'Version', type: :feature do
  let!(:freetown) { create(:forum, name: 'freetown') }

  scenario 'should reload page on version change' do
    visit discover_forums_path

    page.execute_script('window.arguVersion = "0.0.1";')

    page.dismiss_confirm 'A new version of Argu has been released. Would you like to reload this page? (recommended)' do
      click_link(freetown.display_name)
    end

    page.accept_confirm 'A new version of Argu has been released. Would you like to reload this page? (recommended)' do
      click_link('New discussion')
    end

    click_link('New idea')
    expect(page).to have_content('Sign up')
  end
end
