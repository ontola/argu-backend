# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Group', type: :feature do
  define_freetown('nederland')
  let!(:user) { create_member(nederland) }
  let!(:super_admin) { create_super_admin(nederland) }
  let!(:group) { create(:group, parent: nederland.page.edge) }

  scenario 'Admin adds a group member' do
    sign_in(super_admin)

    visit(settings_page_path(nederland.page, tab: :groups))

    click_link(group.name)

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
