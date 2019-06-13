# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User email' do
  define_freetown
  let(:user) { create(:user) }

  scenario 'User adds email address' do
    sign_in user
    new_email = 'new_email@example.com'

    create_email_mock(
      'confirm_secondary',
      user.email,
      confirmationToken: /.+/,
      email: new_email
    )

    RequestStore.store[:old_frontend] = true
    visit settings_iri('/u', tab: :authentication)
    expect(page).to have_content('Email confirmed')
    expect(page).not_to have_link('Send confirmation mail')

    click_link 'Add email'

    all("input[name*='user[email_addresses_attributes]']:not(:disabled)")
      .find("input[name*='[email]']")
      .first
      .set(new_email)

    fill_in 'user_current_password', with: user.password

    next_id = EmailAddress.last.id + 1
    new_email_count = worker_count_string(
      'BroadcastWorker',
      "['resource_id' => #{next_id}, 'resource_type' => 'emailAddresses', 'event' => 'create', 'changes' => nil]"
    )
    assert_difference('EmailAddress.count' => 1, new_email_count => 1) do
      click_button 'Save'
      confirm_msg = 'We have send you a mail to the new address. Please '\
        'confirm the change by clicking the link in this mail.'

      expect(page).to have_content(confirm_msg)
    end

    expect(page).to have_current_path("#{settings_iri("/#{argu.url}/u").path}?tab=authentication")
    expect(page).to have_link('Send confirmation mail')
    assert_email_sent
  end
end
