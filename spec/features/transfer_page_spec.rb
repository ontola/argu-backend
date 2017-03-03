# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Transfer Page', type: :feature do
  define_holland('nederland')
  let!(:holland_member) { create_member(nederland) }
  let!(:user) { create(:user_with_votes, first_name: 'testuser') }

  scenario 'Owner transfers a page' do
    sign_in(nederland.page.owner.profileable)

    visit(settings_page_path(nederland.page, tab: :advanced))

    click_link('Move')

    expect(page).to have_content 'Are you absolutely sure?'

    within('.modal form.page') do
      fill_in 'page_confirmation_string', with: 'transfer'
      fill_in_select with: user.first_name

      click_button 'I understand the consequences, transfer ownership of this organization.'
    end

    expect(find('div.alert', text: 'Organization transferred')).to be_present
  end
end
