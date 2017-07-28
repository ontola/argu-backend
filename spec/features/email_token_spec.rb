# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Email token', type: :feature do
  define_freetown
  let!(:user) { create_member(freetown) }
  let!(:group) { create(:group, parent: freetown.page.edge) }
  let!(:super_admin) { create_super_admin(freetown) }

  scenario 'Owner adds and retracts email token' do
    sign_in(super_admin)

    visit(settings_group_path(group, tab: :invite))

    expect(page).to have_css '.email-token-management table tbody tr', count: 2

    within('.select-users-and-emails') do
      fill_in_select with: user.first_name
    end

    click_button('Send invites')

    expect(page).to have_css '.email-token-management table tbody tr', count: 3

    within('.email-token-management table tbody tr:first-child') do
      page.accept_confirm 'Are you sure you want to retract this link?' do
        click_link('retract')
      end
    end

    expect(page).to have_css '.email-token-management table tbody tr', count: 2
  end
end
