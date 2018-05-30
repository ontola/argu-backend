# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Invite', type: :feature do
  define_freetown
  let(:motion) { create(:motion, :with_arguments, :with_votes, parent: freetown) }
  let(:user) { create(:user) }
  let(:administrator) { create_administrator(freetown) }

  scenario 'Administrator invites user for existing group' do
    sign_in administrator
    visit(freetown.iri_path)
    page.find('.cover-buttons-container .share-menu a').click
    click_link('Invite')
    within '.modal' do
      expect(page).to have_content('Invite people')
      within('.select-users-and-emails') do
        fill_in_select with: user.first_name
      end
      within('.Select-group') do
        fill_in_select with: 'Admins'
      end
      click_button('Send invites')
    end
    expect(page).to have_content('The invitations are being sent')
  end

  scenario 'Administrator invites user for new group' do
    sign_in administrator
    visit(freetown.iri_path)
    page.find('.cover-buttons-container .share-menu a').click
    click_link('Invite')
    within '.modal' do
      expect(page).to have_content('Invite people')
      within('.select-users-and-emails') do
        fill_in_select with: user.first_name
      end
      within('.Select-group') do
        fill_in_select with: 'Add group'
      end
      assert_differences([['Group.count', 1]]) do
        within('.form-small') do
          fill_in 'group-name', with: 'Civilians'
          fill_in 'group-name-singular', with: 'Civilian'
          click_button('Create')
        end
        expect(page).to have_content('Civilians (may participate)')
      end
      click_button('Send invites')
    end
    expect(page).to have_content('The invitations are being sent')
  end
end
