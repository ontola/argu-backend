# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User Password', type: :feature do
  define_freetown
  let(:user) { create(:user) }
  let(:user_omni_both) do
    user = create(:user)
    user.identities.new uid: '111907595807605',
                        provider: 'facebook'
    user.save!
    user
  end
  let(:user_omni_only) do
    user = build(:user, :no_password)
    user.identities.new uid: '111907595807605',
                        provider: 'facebook'
    user.save!
    user
  end

  ####################################
  # As Guest
  ####################################
  scenario 'guest should request a password reset email' do
    visit new_user_password_path
    fill_in 'user_email', with: user.email
    click_button 'Send reset instructions'
    expect(page).to have_content('You will receive an email shortly with instructions to reset your password.')
  end

  ####################################
  # As User
  ####################################
  scenario 'user no omni should change their password' do
    sign_in_manually user

    visit "#{settings_iri('/u').path}?tab=authentication"
    expect(page).to have_current_path "#{settings_iri('/u').path}?tab=authentication"

    expect(page).to have_content('Edit password')
    expect(page).to have_content('Confirm password')
    expect(page).to have_content('Current password')

    new_password = 'new password'
    within("#edit_user_#{user.id}") do
      fill_in 'user_password', with: new_password
      fill_in 'user_password_confirmation', with: new_password
      fill_in 'user_current_password', with: user.password
      click_button 'Save'
    end
    expect(page).to have_content('Changes saved successfully')
    expect(page).to have_current_path "/#{argu.url}#{settings_iri('/u').path}?tab=authentication"

    visit destroy_user_session_path
    expect(page).to have_current_path(root_path)
    expect(page).to have_content 'You have signed out successfully.'

    visit new_user_session_path
    expect do
      within('#new_user') do
        fill_in 'user_email', with: user.email
        fill_in 'user_password', with: new_password
        click_button 'Log in'
      end
      expect(page).to have_current_path resource_iri(freetown).path
    end.to change { Doorkeeper::AccessToken.count }.by(1)
  end

  scenario 'user both omni should change their password' do
    sign_in user_omni_both

    visit "#{settings_iri('/u').path}?tab=authentication"
    expect(page).to have_current_path "#{settings_iri('/u').path}?tab=authentication"

    expect(page).to have_content('Edit password')
    expect(page).to have_content('Confirm password')
    expect(page).to have_content('Current password')

    new_password = 'new password'
    within("#edit_user_#{user_omni_both.id}") do
      fill_in 'user_password', with: new_password
      fill_in 'user_password_confirmation', with: new_password
      fill_in 'user_current_password', with: user_omni_both.password
      click_button 'Save'
    end
    expect(page).to have_current_path "#{settings_iri('/u').path}?tab=authentication"

    expect(page).to have_content('User settings')
  end

  scenario 'user omni both should not request a password reset email' do
    sign_in user_omni_both

    visit "#{settings_iri('/u').path}?tab=authentication"
    expect(page).not_to have_content("You don't have a password yet, because you signed up "\
                                       'using a linked account. Do you want to set a password?')
  end

  scenario 'user only omni should not change their password' do
    sign_in user_omni_only

    visit "#{settings_iri('/u').path}?tab=authentication"
    expect(page).not_to have_content('Password')
    expect(page).not_to have_content('Confirm password')
    expect(page).not_to have_content('Current password')
  end

  scenario 'user only omni should request a password reset email' do
    OmniAuth.config.mock_auth[:facebook] =
      facebook_auth_hash(email: user_omni_only.email,
                         first_name: user_omni_only.first_name,
                         last_name: user_omni_only.last_name,
                         middle_name: nil,
                         uid: '111907595807605')
    create_email_mock('reset_password_instructions', user_omni_only.email, token: /.+/)

    expect(user_omni_only.has_password?).to be_falsey

    visit new_user_session_path

    click_link 'Log in with Facebook'

    expect(page).to have_selector('.navbar-item.navbar-profile')
    visit "#{settings_iri('/u').path}?tab=authentication"
    expect(page).to have_content('User settings')
    expect(page).to have_content("You don't have a password yet, because you signed up using a linked account. "\
                                   'Do you want to set a password?')

    Sidekiq::Testing.inline! do
      click_link 'send-instructions'
      expect(page).to have_content('You will receive an email shortly with instructions to reset your password.')
    end

    match = assert_email_sent(skip_sidekiq: true)
    token = Rack::Utils.parse_nested_query(match.body)['email']['options']['token']
    visit edit_user_password_path(reset_password_token: token)

    expect(page).to have_content('Choose a password')
    within('#new_user') do
      fill_in 'user_password', with: 'new_password'
      fill_in 'user_password_confirmation', with: 'new_password'
      click_button 'Edit'
    end

    expect(page).to have_content('You are already authenticated.')
    expect(user_omni_only.reload.has_password?).to be_truthy
  end
end
