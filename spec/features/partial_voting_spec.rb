# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Partial Voting', type: :feature do
  define_freetown
  let(:question) { create(:question, parent: freetown) }
  subject! { create(:motion, parent: question) }

  ####################################
  # As Guest
  ####################################

  scenario 'Guest should vote on a motion' do
    nominatim_netherlands

    visit question
    expect(page).to have_content(subject.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('a', text: 'Disagree').click

    user_attr = attributes_for(:user)

    create_email_mock(
      'confirm_votes',
      user_attr[:email],
      confirmationToken: /.+/,
      motions: [{display_name: subject.display_name, option: 'con', url: resource_iri(subject)}]
    )

    Sidekiq::Testing.inline! do
      within('.opinion-form') do
        fill_in 'user[email]', with: user_attr[:email]
        click_button 'Continue'

        expect(page).to have_content('By creating an Argu account you agree to our')

        click_button 'Confirm'

        expect(page).not_to have_content('By creating an Argu account you agree to our')
      end
    end

    expect(page).to have_current_path(resource_iri(question).path.to_s)
    expect(page).to have_css('.btn-con[data-voted-on=true]')
    expect(page).to have_content('Please confirm your vote by clicking the link we\'ve sent to ')
    assert_email_sent(skip_sidekiq: true)
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  scenario 'User should vote on a motion' do
    sign_in(user)

    visit question
    expect(page).to have_content(subject.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('span', text: 'Disagree').click
    expect(page).to have_css('.btn-con[data-voted-on=true]')

    visit question
    expect(page).to have_css('.btn-con[data-voted-on=true]')
  end

  ####################################
  # As Initiator
  ####################################
  let(:initiator) { create_initiator(freetown) }

  scenario 'Initiator should vote on a motion' do
    sign_in(initiator)

    visit question
    expect(page).to have_content(subject.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('span', text: 'Disagree').click
    expect(page).to have_css('.btn-con[data-voted-on=true]')

    visit question
    expect(page).to have_css('.btn-con[data-voted-on=true]')
  end
end
