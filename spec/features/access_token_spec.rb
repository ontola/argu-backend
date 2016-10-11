# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Access tokens', type: :feature do
  define_helsinki(attributes: {name: 'helsinki'})
  let!(:motion) do
    create(:motion,
           title: 'proposition',
           parent: helsinki.edge)
  end
  let(:helsinki_key) { create(:access_token, item: helsinki) }

  @javascript
  scenario 'should register and become a member with an access token and preserve vote' do
    nominatim_netherlands

    visit forum_path(helsinki.url, at: helsinki_key.access_token)
    expect(page).to have_content 'helsinki'

    click_link motion.title

    expect(page).to have_content('content')

    click_link 'Neutral'
    expect(page).to have_content 'Sign up'

    click_link 'Sign up with email'
    expect(page).to have_current_path new_user_registration_path(r: new_motion_vote_path(motion,
                                                                                         confirm: true,
                                                                                         vote: {for: :neutral}))

    user_attr = attributes_for(:user)
    within('#new_user') do
      fill_in 'user_email', with: user_attr[:email]
      fill_in 'user_password', with: user_attr[:password]
      fill_in 'user_password_confirmation', with: user_attr[:password]
      click_button 'Sign up'
    end

    expect(page).to have_current_path setup_users_path
    click_button 'Next'

    profile_attr = attributes_for(:profile)
    within('form') do
      fill_in 'user_first_name', with: user_attr[:first_name]
      fill_in 'user_last_name', with: user_attr[:last_name]
      fill_in 'user_profile_attributes_about', with: profile_attr[:about]
      click_button 'Next'
    end

    click_button 'Neutral'

    expect(page).to have_content motion.title
    expect(page).to have_css 'a.btn-neutral[data-voted-on=true]'
  end
end
