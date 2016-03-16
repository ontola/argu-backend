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

  def log_in_user(user = FactoryGirl.create(:user))
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
    log_in_user user

    visit settings_path
    expect(current_path).to eq settings_path

    expect(page).to have_content('EDIT PASSWORD')
    expect(page).to have_content('CONFIRM PASSWORD')
    expect(page).to have_content('CURRENT PASSWORD')

    new_password = 'new password'
    expect {
      within("#edit_user_#{user.id}") do
        fill_in 'user_password', with: new_password
        fill_in 'user_password_confirmation', with: new_password
        fill_in 'user_current_password', with: user.password
        click_button 'Save'
      end
    }.to change {
      Sidekiq::Worker.jobs.size
    }.by(1)
    expect(current_path).to eq settings_path

    visit destroy_user_session_path
    expect(page).to have_content 'You have signed out successfully.'

    visit new_user_session_path

    within('#new_user') do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: new_password
      click_button 'Log in'
    end
    expect(current_path).to eq info_path(:about)
    expect(page).to have_content 'Welcome back!'
  end

  scenario 'user both omni should change their password' do
    log_in_user user_omni_both

    visit settings_path
    expect(current_path).to eq settings_path

    expect(page).to have_content('EDIT PASSWORD')
    expect(page).to have_content('CONFIRM PASSWORD')
    expect(page).to have_content('CURRENT PASSWORD')

    expect {
      new_password = 'new password'
      within("#edit_user_#{user_omni_both.id}") do
        fill_in 'user_password', with: new_password
        fill_in 'user_password_confirmation', with: new_password
        fill_in 'user_current_password', with: user_omni_both.password
        click_button 'Save'
      end
    }.to change {
      Sidekiq::Worker.jobs.size
    }.by(1)

    expect(current_path).to eq settings_path
    expect(page).to have_content('User settings')
  end

  scenario 'user omni both should not request a password reset email' do
    log_in_user user_omni_both

    visit settings_path
    expect(page).not_to have_content("You don't have a password yet, because you signed up using a linked account. Do you want to set a password?")
  end

  scenario 'user only omni should not change their password' do
    log_in_user user_omni_only

    visit settings_path
    expect(page).not_to have_content('password')
    expect(page).not_to have_content('confirm password')
    expect(page).not_to have_content('current password')
  end

  scenario 'user only omni should request a password reset email' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash(email: user_omni_only.email,
                                                              first_name: user_omni_only.first_name,
                                                              last_name: user_omni_only.last_name,
                                                              middle_name: nil)
    visit new_user_session_path

    click_link 'Log in with Facebook'

    expect(page).to have_selector('.navbar-item.navbar-profile')
    visit settings_path
    expect(page).to have_content('User settings')
    expect(page).to have_content("You don't have a password yet, because you signed up using a linked account. Do you want to set a password?")

    expect {
      click_link 'send-instructions'
      expect(page).to have_content("You will receive an email shortly with instructions to reset your password.")
    }.to change {
      Sidekiq::Worker.jobs.size
    }.by(1)

  end
end
