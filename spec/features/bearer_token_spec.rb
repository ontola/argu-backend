# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Bearer token', type: :feature do
  define_freetown
  let!(:group) { create(:group, parent: freetown.page.edge) }
  let!(:owner) { create_owner(freetown) }

  scenario 'Owner adds and retracts bearer token' do
    sign_in(owner)

    visit(settings_group_path(group, tab: :invite))

    expect(page).to have_css 'table tbody tr', count: 2

    click_button('Generate token')

    expect(page).to have_css 'table tbody tr', count: 3

    within('table tbody tr:first-child') do
      page.accept_confirm 'Are you sure you want to retract this token?' do
        click_link('retract')
      end
    end

    expect(page).to have_css 'table tbody tr', count: 2
  end
end
