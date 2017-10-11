# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Partial Voting', type: :feature do
  define_freetown
  let(:question) { create(:question, parent: freetown.edge) }
  subject! { create(:motion, parent: question.edge) }

  ####################################
  # As Guest
  ####################################

  scenario 'Guest should vote on a motion' do
    nominatim_netherlands

    visit question_path(question)
    expect(page).to have_content(subject.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('a', text: 'I\'m against').click

    user_attr = attributes_for(:user)

    create_email_mock(
      'ConfirmationsMailer',
      'confirm_votes',
      user_attr[:email],
      confirmationToken: /.+/,
      motions: [{display_name: subject.display_name, option: 'con', url: subject.context_id}]
    )

    Sidekiq::Testing.inline! do
      within('.opinion-form') do
        fill_in 'user[email]', with: user_attr[:email]
        click_button 'Continue'

        click_button 'Confirm'
      end
    end

    expect(page).to have_current_path(question_path(question))
    expect(page).to have_css('.btn-con[data-voted-on=true]')
    expect(page).to have_content('Please confirm your vote by clicking the link we\'ve send to ')
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  scenario 'User should vote on a motion' do
    sign_in(user)

    visit question_path(question)
    expect(page).to have_content(subject.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('span', text: 'I\'m against').click
    expect(page).to have_css('.btn-con[data-voted-on=true]')

    visit question_path(question)
    expect(page).to have_css('.btn-con[data-voted-on=true]')
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  scenario 'Member should vote on a motion' do
    sign_in(member)

    visit question_path(question)
    expect(page).to have_content(subject.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('span', text: 'I\'m against').click
    expect(page).to have_css('.btn-con[data-voted-on=true]')

    visit question_path(question)
    expect(page).to have_css('.btn-con[data-voted-on=true]')
  end
end
