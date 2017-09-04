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
    Sidekiq::Testing.inline! do
      within('.opinion-form') do
        fill_in 'user[email]', with: user_attr[:email]
        click_button 'Save'
      end

      expect(page).to have_current_path setup_users_path
      click_button 'Next'

      profile_attr = attributes_for(:profile)
      within('form') do
        fill_in 'user_first_name', with: user_attr[:first_name]
        fill_in 'user_last_name', with: user_attr[:last_name]
        fill_in 'user_profile_attributes_about', with: profile_attr[:about]
        click_button 'Next'
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
