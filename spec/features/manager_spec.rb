# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Manager', type: :feature do
  define_freetown('nederland')
  let!(:user) { create_member(nederland) }
  let!(:super_admin) { create_super_admin(nederland) }

  scenario 'Admin adds a manager' do
    sign_in(super_admin)

    visit(settings_page_path(argu, tab: :groups))

    click_link('Managers')

    expect(page).to have_content 'Members'

    within('.box') do
      click_link('Invite')
    end

    within('form.group') do
      fill_in_select with: user.first_name
      click_button 'Save'
    end

    expect(
      find(".members .#{user.profile.identifier} .name",
           text: user.display_name)
    ).to be_present
  end
end
