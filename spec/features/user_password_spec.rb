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

    expect(page).to have_content('WACHTWOORD WIJZIGEN')
    expect(page).to have_content('WACHTWOORD BEVESTIGEN')
    expect(page).to have_content('HUIDIG WACHTWOORD')

    new_password = 'new password'
    expect {
      within("#edit_user_#{user.id}") do
        fill_in 'user_password', with: new_password
        fill_in 'user_password_confirmation', with: new_password
        fill_in 'user_current_password', with: user.password
        click_button 'Opslaan'
      end
    }.to change {
      Sidekiq::Worker.jobs.size
    }.by(1)
    expect(current_path).to eq settings_path

    visit destroy_user_session_path
    expect(page).to have_content 'Je bent succesvol uitgelogd, tot ziens.'

    visit new_user_session_path

    within('#new_user') do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: new_password
      click_button 'Log in'
    end
    expect(current_path).to eq info_path(:about)
    expect(page).to have_content 'Welkom terug!'
  end

  scenario 'user both omni should change their password' do
    log_in_user user_omni_both

    visit settings_path
    expect(current_path).to eq settings_path

    expect(page).to have_content('WACHTWOORD WIJZIGEN')
    expect(page).to have_content('WACHTWOORD BEVESTIGEN')
    expect(page).to have_content('HUIDIG WACHTWOORD')

    expect {
      new_password = 'new password'
      within("#edit_user_#{user_omni_both.id}") do
        fill_in 'user_password', with: new_password
        fill_in 'user_password_confirmation', with: new_password
        fill_in 'user_current_password', with: user_omni_both.password
        click_button 'Opslaan'
      end
    }.to change {
      Sidekiq::Worker.jobs.size
    }.by(1)

    expect(current_path).to eq settings_path
    expect(page).to have_content('Gebruikersinstellingen')
  end

  scenario 'user omni both should not request a password reset email' do
    log_in_user user_omni_both

    visit settings_path
    expect(page).not_to have_content('Je hebt nog geen wachtwoord omdat je je via social media hebt aangemeld. Wil je een wachtwoord aanmaken?')
  end

  scenario 'user only omni should not change their password' do
    log_in_user user_omni_only

    visit settings_path
    expect(page).not_to have_content('wachtwoord')
    expect(page).not_to have_content('wachtwoord bevestigen')
    expect(page).not_to have_content('huidig wachtwoord')
  end

  scenario 'user only omni should request a password reset email' do
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(
      {
        provider: 'facebook',
        uid: '111907595807605',
        credentials: {
          token: 'CAAKvnjt9N54BACAJ6Uj5LFywuhmo5vy2VUyvBqtZAPrZAUH10sy4KgxZAU0mZConMqV9ZB6kO4eZCC3Y822NbZCXdBjZAjUE9ubUscZBZB5WGHn32jIn2NU7UZAVYbAYWcmfg0vutOLZAw3LDs8YE2O5k2Nwde7zzMK1hyBrZC30wvIFnbjoaGegXEZBbL1fyJjGTUBLADCOczzZAHkDhH3mYqJp2y2'
        },
        info: {
          email: user_omni_only.email,
          first_name: user_omni_only.first_name,
          last_name: user_omni_only.last_name
        }
      })
    visit new_user_session_path

    click_link 'Log in with Facebook'

    expect(page).to have_content(user_omni_only.first_name)
    visit settings_path
    expect(page).to have_content('Gebruikersinstellingen')
    expect(page).to have_content('Je hebt nog geen wachtwoord omdat je je via social media hebt aangemeld. Wil je een wachtwoord aanmaken?')

    expect {
      click_link 'send-instructions'
    }.to change {
      Sidekiq::Worker.jobs.size
    }.by(1)

  end
end
