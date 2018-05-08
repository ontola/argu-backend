# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Email token', type: :feature do
  define_freetown
  let!(:user) { create_initiator(freetown) }
  let!(:group) { create(:group, parent: freetown.page.edge) }
  let!(:administrator) { create_administrator(freetown) }

  scenario 'Owner adds and retracts email token' do
    sign_in(administrator)

    visit(settings_iri_path(group, tab: :invite))

    expect(page).to have_css '.email-token-management table tbody tr', count: 2

    within('.select-users-and-emails') do
      fill_in_select with: user.first_name
    end

    click_button('Send invites')

    within('.email-token-management table tbody tr:first-child') do
      page.accept_confirm 'Are you sure you want to retract this link?' do
        click_link('retract')
      end
    end
  end
end
