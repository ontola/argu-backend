# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'User email' do
  define_freetown
  let(:user) { create(:user) }

  background do
    clear_emails
  end

  scenario 'User adds email address' do
    sign_in user
    new_email = 'new_email@example.com'

    visit settings_user_path(tab: :authentication)
    expect(page).to have_content('Email confirmed')
    expect(page).not_to have_link('Send confirmation mail')

    click_link 'Add email'
    all("input[name*='user[emails_attributes]']:not(:disabled)")
      .find("input[name*='[email]']")
      .first
      .set(new_email)

    fill_in 'user_current_password', with: user.password

    assert_differences([['Email.count', 1],
                        ['Sidekiq::Worker.jobs.count', 1]]) do
      click_button 'Save'
      confirm_msg = 'We have send you a mail to the new address. Please '\
        'confirm the change by clicking the link in this mail.'

      expect(page).to have_content(confirm_msg)
    end

    expect(page).to have_current_path(settings_user_path(tab: :authentication))
    expect(page).to have_link('Send confirmation mail')

    # Send mail
    Sidekiq::Extensions::DelayedMailer.process_job(Sidekiq::Worker.jobs.last)

    open_email(new_email)

    expect(current_email.subject).to eq 'Confirm your e-mail address'
    expect(current_email).to have_content "You can confirm your account's " \
                                            'e-mail address by pressing the link below.'

    current_email.click_link 'Confirm your e-mail'
    expect(page).to have_current_path(root_path)
    visit settings_user_path(tab: :authentication)
    expect(page).not_to have_link('Send confirmation mail')
    expect(page).to have_selector("input[value='#{new_email}']")
  end
end
