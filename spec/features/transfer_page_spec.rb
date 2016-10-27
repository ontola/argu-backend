# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Transfer Page', type: :feature do
  define_holland('nederland')
  let!(:holland_member) { create_member(nederland) }
  let!(:user) { create(:user_with_votes, first_name: 'testuser') }

  scenario 'User transfers a page' do
    login_as(nederland.page.owner.profileable, scope: :user)

    visit(settings_page_path(nederland.page, tab: :grants))

    click_link('Move')
    within('form.page') do
      fill_in 'page_confirmation_string', with: 'transfer'
      fill_in_select with: user.first_name

      click_button 'I understand the consequences, transfer ownership of this organization.'
    end

    expect(find('div.alert', text: 'Organization transferred')).to be_present
  end
end
