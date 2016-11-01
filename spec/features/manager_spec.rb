# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Manager', type: :feature do
  define_freetown('nederland')
  let!(:user) { create_member(nederland) }
  let!(:owner) { create_owner(nederland) }

  scenario 'Owner adds a manager' do
    sign_in(owner)

    visit(settings_forum_path(nederland, tab: :groups))

    click_link('Managers')

    expect(page).to have_content 'Members'

    click_link('Add Manager')
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
