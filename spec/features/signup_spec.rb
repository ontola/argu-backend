# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Signup', type: :feature do
  include ApplicationHelper
  include UsersHelper
  let!(:default_forum) { create(:setting, key: 'default_forum', value: default.uuid) }
  define_freetown('default', attributes: {name: 'default'})
  define_freetown(attributes: {name: 'freetown'})
  let!(:motion) { create(:motion, parent: freetown) }
  let(:netherlands) { create(:place, address: {'country_code' => 'nl'}) }

  scenario 'should register with country only' do
    netherlands

    visit new_user_session_path

    click_link 'Sign up with email'

    user_attrs = attributes_for(:user)

    create_email_mock(
      'confirmation',
      user_attrs[:email],
      token_url: /.+/
    )

    expect(page).not_to have_content('Sign up with email')
    within('#new_user') do
      fill_in 'user_email', with: user_attrs[:email]
      fill_in 'user_password', with: user_attrs[:password]
      fill_in 'user_password_confirmation', with: user_attrs[:password_confirmation]
      click_button 'Sign up'
    end

    expect(page).to have_current_path setup_users_path
    within('.formtastic.user') do
      click_button 'Next'
    end

    fill_in_select '#user_home_placement_attributes_country_code_input',
                   with: 'Netherlands',
                   selector: /Netherlands$/
    click_button 'Save'

    expect(page).to have_current_path(resource_iri(User.last, root: argu).path)
    expect(User.last.country).to eq('NL')
    assert_email_sent
  end
end
