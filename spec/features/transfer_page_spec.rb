require 'rails_helper'

RSpec.feature 'Transfer Page', type: :feature do

  let!(:nederland) do
    FactoryGirl.create(:populated_forum,
                       name: 'nederland')
  end
  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }
  let!(:holland_member) { create_member(holland) }
  let!(:user) { FactoryGirl.create(:user_with_votes, first_name: 'testuser') }

  scenario 'User transfers a page' do
    login_as(holland.page.owner.profileable, :scope => :user)

    visit(settings_page_path(holland.page, tab: :managers))

    click_link('transfer')
    within('form.page') do
      fill_in 'page_repeat_name', with: holland.page.shortname.shortname
      if Capybara.current_driver == :poltergeist
        selector = '.Select-control .Select-placeholder'
      else
        selector = '.Select-control .Select-input input'
      end
      input_field = find(selector).native
      input_field.send_keys user.first_name
      find('.Select-option').click

      click_button 'Ik begrijp de consequenties, draag deze pagina over'
    end

    expect(find('div.alert', text: 'Organisatie overgedragen')).to be_present
  end

end
