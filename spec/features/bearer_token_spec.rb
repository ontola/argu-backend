# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Bearer token', type: :feature do
  define_freetown
  let!(:group) { create(:group, parent: argu) }
  let!(:administrator) { create_administrator(freetown) }

  scenario 'Owner adds and retracts bearer token' do
    sign_in(administrator)

    RequestStore.store[:old_frontend] = true
    visit(settings_iri(group, tab: :invite))

    expect(page).to have_css '.bearer-token-management table tbody tr', count: 2

    click_button('Generate link')

    within('.bearer-token-management table tbody tr:first-child') do
      page.accept_confirm 'Are you sure you want to retract this link?' do
        click_link('retract')
      end
    end
  end
end
