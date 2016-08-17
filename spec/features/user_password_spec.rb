require 'rails_helper'

RSpec.feature 'User Password', type: :feature do
  let(:user) { create(:user) }
  let(:user_omni_both) do
    user = create(:user)
    user.identities.new uid: '111907595807605',
                        provider: 'facebook'
    user.save!
    user
  end
  let(:user_omni_only) do
    user = build(:user,
                 encrypted_password: nil,
                 password: nil,
                 password_confirmation: nil)
    user.identities.new uid: '111907595807605',
                        provider: 'facebook'
    user.save!
    user
  end

  def sign_in(user = create(:user))
    visit new_user_session_path
    within('#new_user') do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
      click_button 'Log in'
    end
  end

  ####################################
  # As User
  ####################################
  scenario 'user no omni should change their password' do
    sign_in user

    visit settings_path(tab: :authentication)
    expect(page).to have_current_path settings_path(tab: :authentication)

    expect(page).to have_content('Edit password')
    expect(page).to have_content('Confirm password')
    expect(page).to have_content('Current password')

    new_password = 'new password'
    expect do
      within("#edit_user_#{user.id}") do
        fill_in 'user_password', with: new_password
        fill_in 'user_password_confirmation', with: new_password
        fill_in 'user_current_password', with: user.password
        click_button 'Save'
      end
    end.to change {
      Sidekiq::Worker.jobs.size
    }.by(1)
    expect(page).to have_current_path settings_path(tab: :authentication)

    visit destroy_user_session_path
    expect(page).to have_content 'You have signed out successfully.'

    visit new_user_session_path

    within('#new_user') do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: new_password
      click_button 'Log in'
    end
    expect(page).to have_current_path info_path(:about)
    expect(page).to have_content 'Welcome back!'
  end

  scenario 'user both omni should change their password' do
    sign_in user_omni_both

    visit settings_path(tab: :authentication)
    expect(page).to have_current_path settings_path(tab: :authentication)

    expect(page).to have_content('Edit password')
    expect(page).to have_content('Confirm password')
    expect(page).to have_content('Current password')

    expect do
      new_password = 'new password'
      within("#edit_user_#{user_omni_both.id}") do
        fill_in 'user_password', with: new_password
        fill_in 'user_password_confirmation', with: new_password
        fill_in 'user_current_password', with: user_omni_both.password
        click_button 'Save'
      end
    end.to change {
      Sidekiq::Worker.jobs.size
    }.by(1)

    expect(page).to have_current_path settings_path(tab: :authentication)
    expect(page).to have_content('User settings')
  end

  scenario 'user omni both should not request a password reset email' do
    sign_in user_omni_both

    visit settings_path(tab: :authentication)
    expect(page).not_to have_content("You don't have a password yet, because you signed up "\
                                       "using a linked account. Do you want to set a password?")
  end

  scenario 'user only omni should not change their password' do
    login_as user_omni_only, scope: :user

    visit settings_path(tab: :authentication)
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
    visit new_user_session_path

    click_link 'Log in with Facebook'

    expect(page).to have_selector('.navbar-item.navbar-profile')
    visit settings_path(tab: :authentication)
    expect(page).to have_content('User settings')
    expect(page).to have_content("You don't have a password yet, because you signed up using a linked account. "\
                                   "Do you want to set a password?")

    expect do
      click_link 'send-instructions'
      expect(page).to have_content('You will receive an email shortly with instructions to reset your password.')
    end.to change {
      Sidekiq::Worker.jobs.size
    }.by(1)
  end
end
