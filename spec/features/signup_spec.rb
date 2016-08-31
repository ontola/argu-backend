require 'rails_helper'

RSpec.feature 'Signup', type: :feature do
  let!(:default_forum) { create(:setting, key: 'default_forum', value: 'default') }
  define_freetown('default', attributes: {name: 'default'})
  define_freetown(attributes: {name: 'freetown'})
  let!(:motion) { create(:motion, parent: freetown.edge) }

  scenario 'should register w/ oauth and preserve vote on non-default forum' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash

    visit root_path
    expect(page).to have_content 'default'
    expect(page).to have_current_path forum_path(default)

    visit forum_path(freetown)
    expect(page).to have_content 'freetown'

    click_link motion.title
    expect(page).to have_content(motion.content)

    click_on_vote 'Neutral'
    expect(page).to have_content 'Sign up'

    click_link 'Log in with Facebook'

    expect(page).to have_current_path setup_users_path
    click_button 'Volgende'

    click_button 'Geen van beide'

    expect(page).to have_content motion.title
    expect(page).to have_css 'a.btn-neutral[data-voted-on=true]'
  end

  scenario 'should register with country only' do
    nominatim_netherlands

    visit new_user_session_path

    click_link 'Sign up with email'

    user_attrs = attributes_for(:user)

    within('#new_user') do
      fill_in 'user_email', with: user_attrs[:email]
      fill_in 'user_password', with: user_attrs[:password]
      fill_in 'user_password_confirmation', with: user_attrs[:password_confirmation]
      click_button 'Sign up'
    end

    expect(page).to have_current_path setup_users_path
    click_button 'Next'

    within('#user_home_placement_attributes_country_code_input') do
      input_field = find('.Select-control .Select-input input').native
      input_field.send_keys 'Netherlands'
      find('.Select-option', text: /Netherlands$/).click
    end
    click_button 'Next'

    expect(page).to have_current_path(user_path(User.last))
  end
end
