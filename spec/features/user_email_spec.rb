require 'rails_helper'

RSpec.feature 'User email' do
  let(:user) { create(:user, :confirmed) }

  background do
    clear_emails
  end

  scenario 'User changes email address' do
    sign_in user
    new_email = 'new_email@example.com'

    visit settings_path
    expect(page).to have_content('Email confirmed')
    expect(page).not_to have_content('Pending email')

    Sidekiq::Testing.inline! do
      within('form.user') do
        fill_in 'user_email', with: new_email
        fill_in 'user_current_password', with: user.password
        click_button 'Save'
      end
    end

    expect(page).to have_content("Pending email: #{new_email}")

    open_email(new_email)

    expect(current_email.subject).to eq 'Confirm your e-mail address'
    expect(current_email).to have_content "You can confirm your account's " \
                                            'e-mail address by pressing the link below.'

    current_email.click_link 'Confirm your e-mail'
    expect(page).to have_current_path(info_path(:about))
    visit settings_path
    expect(page).to have_selector("input[value='#{new_email}']")
  end
end
