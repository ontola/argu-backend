# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Direct message', type: :feature do
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }
  let(:administrator) { create_administrator(freetown) }

  scenario 'Administrator send direct message' do
    ActsAsTenant.with_tenant(motion.root) do
      create_email_mock(
        'direct_message',
        motion.publisher.email,
        actor: {
          display_name: administrator.display_name,
          iri: administrator.iri,
          thumbnail: administrator.profile.default_profile_photo.thumbnail
        },
        body: 'Body of email',
        email: administrator.email,
        resource: {iri: resource_iri(motion).to_s.sub('app.', ''), display_name: motion.display_name},
        subject: 'Subject of email'
      )
    end

    sign_in administrator
    visit(motion)
    page.find('.actions-menu a').click
    click_link('Contact poster')
    within '.modal' do
      expect(page).to have_content('Send message')
      fill_in 'direct_message_subject', with: 'Subject of email'
      fill_in 'direct_message_body', with: 'Body of email'
      click_button('Send')
    end
    expect(page).to have_content('The mail will be sent')

    assert_email_sent(skip_sidekiq: true)
  end
end
