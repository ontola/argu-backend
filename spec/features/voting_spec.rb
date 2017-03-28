# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Voting', type: :feature do
  define_freetown
  let(:question) { create(:question, parent: freetown.edge) }
  let(:motion) { create(:motion, parent: question.edge) }

  ####################################
  # As Guest
  ####################################

  scenario 'Guest should vote on a motion' do
    nominatim_netherlands

    visit motion_path(motion)
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('span span', text: 'Disagree').click
    expect(page).to have_content 'Sign up'

    click_link 'Sign up with email'
    expect(page).to have_current_path new_user_registration_path(r: new_motion_vote_path(motion,
                                                                                         confirm: true))

    user_attr = attributes_for(:user)
    within('#new_user') do
      fill_in 'user_email', with: user_attr[:email]
      fill_in 'user_password', with: user_attr[:password]
      fill_in 'user_password_confirmation', with: user_attr[:password]
      click_button 'Sign up'
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

    click_button 'Disagree'

    expect(page).to have_current_path(motion_path(motion))
    expect(page).to have_css('.btn-con[data-voted-on=true]')
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  scenario 'User should vote on a motion' do
    sign_in(user)

    visit motion_path(motion)
    expect(page).not_to have_content('Opinions')
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    # Click a random dropdown to prevent the follow dropdown from interfering
    click_link('Info')
    find('span span', text: 'Disagree').click
    expect(page).to have_css('.btn-con[data-voted-on=true]')
    expect(page).to have_css('.opinion-form')

    within('.opinion-form') do
      fill_in 'opinion-body', with: 'This is my opinion'

      find('.opinion-form__arguments-selector .box-list-item span', text: 'Add pro').click

      within('.argument-form') do
        fill_in 'argument-title', with: 'New argument'
        fill_in 'argument-body', with: 'Argument body'
        click_button 'Save'
      end
      expect(page).to have_content('Thanks for your vote')
      click_button 'Save'
    end
    expect(page).not_to have_content('Thanks for your vote')

    visit motion_path(motion)
    expect(page).to have_content('Opinions')
    within('.opinion-columns') do
      expect(page).to have_content('This is my opinion')
      expect(page).to have_content('New argument')
    end

    within('.opinion-form') do
      find('span.icon-left', text: 'Edit').click
      expect(page).to have_content('Thanks for your vote')
      find('label.pro-t').click
      click_button 'Save'
    end
    expect(page).not_to have_content('Thanks for your vote')

    visit motion_path(motion)
    expect(page).to have_content('Opinions')
    within('.opinion-columns') do
      expect(page).to have_content('This is my opinion')
      expect(page).not_to have_content('New argument')
    end
  end
end
