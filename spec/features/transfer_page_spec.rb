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
      fill_in 'page_repeat_name', with: nederland.page.shortname.shortname
      selector =
        if Capybara.current_driver == :poltergeist
          '.Select-control .Select-placeholder'
        else
          '.Select-control .Select-input input'
        end
      input_field = find(selector).native
      input_field.send_keys user.first_name
      find('.Select-option').click

      click_button 'I understand the consequences, transfer ownership of this organization.'
    end

    expect(find('div.alert', text: 'Organization transferred')).to be_present
  end
end
