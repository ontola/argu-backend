# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Signup', type: :feature do
  include ApplicationHelper, UsersHelper
  let!(:default_forum) { create(:setting, key: 'default_forum', value: 'default') }
  define_freetown('default', attributes: {name: 'default'})
  define_freetown(attributes: {name: 'freetown'})
  let!(:motion) { create(:motion, parent: freetown.edge) }

  scenario 'should register w/ oauth and preserve vote on non-default forum' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash

    visit root_path
    expect(page).to have_content 'default'
    expect(page).to have_current_path root_path

    visit forum_path(freetown)
    expect(page).to have_content 'freetown'

    click_link motion.title
    expect(page).to have_content(motion.content)

    click_link 'Neutral'
    expect(page).to have_content 'Sign up'

    click_link 'Log in with Facebook'

    expect(page).to have_current_path setup_users_path
    click_button 'Volgende'

    click_button 'Geen van beide'

    expect(page).to have_content motion.title
    expect(page).to have_css 'a.btn-neutral[data-voted-on=true]'
  end

  scenario 'should register w/ oauth and connect account' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash
    facebook_me('EAANZAZBdAOGgUBADbu25EDEen6EXgLfTFGN28R6G9E0vgDQEsLu'\
                'FEMDBNe7v7jUpRCmb4SmSQqcam37vnKszs80z28WBdJEiBHnHmZCwr3Fv33v1w5'\
                'jvGZBE6ACZCZBmqkTewz65Deckyyf9br4Nsxz5dSZAQBJ8uqtFEEEj01ncwZDZD')
    u = create(:user, email: 'bpvjlwt_zuckersen_1467905538@tfbnw.net')

    visit motion_path(motion)
    expect(page).to have_content(motion.content)

    click_link 'Neutral'
    expect(page).to have_content 'Sign up'

    click_link 'Log in with Facebook'
    expect(page).to have_current_path(connect_user_path(u), only_path: true)

    fill_in 'password', with: 'password'
    click_button 'Save'

    expect(page).to have_content('Account connected')
    expect(u.reload.identities.count).to eq(1)

    click_button 'Neutral'

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

    fill_in_select '#user_home_placement_attributes_country_code_input',
                   with: 'Netherlands',
                   selector: /Netherlands$/
    click_button 'Next'

    expect(page).to have_current_path(user_path(User.last))
    expect(User.last.country).to eq('NL')
  end
end
