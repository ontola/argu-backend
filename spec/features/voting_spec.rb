# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Voting', type: :feature do
  define_freetown
  let(:question) { create(:question, parent: freetown) }
  let(:motion) { create(:motion, parent: question) }

  ####################################
  # As Guest
  ####################################
  scenario 'Guest should vote on a motion, register, leave an opinion, edit the opinion and confirm' do
    user_attr = attributes_for(:user)

    create_email_mock(
      'confirm_votes',
      user_attr[:email],
      confirmationToken: /.+/,
      motions: [{display_name: motion.display_name, option: 'con', url: motion.iri}]
    )

    visit motion
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('span', text: 'Disagree').click

    Sidekiq::Testing.inline! do
      within('.opinion-form') do
        fill_in 'user[email]', with: user_attr[:email]
        click_button 'Continue'
      end

      assert_difference('Vote.count' => 1, 'Edge.where(confirmed: false).count' => 1) do
        expect(page).to have_content('By creating an Argu account you agree to our')

        click_button 'Confirm'

        expect(page).to have_current_path motion.iri_path

        expect(page).not_to have_content('By creating an Argu account you agree to our')
      end
    end

    find_field('opinion-body').click
    within('.opinion-form') do
      find('.opinion-form__arguments-selector .box-list-item--subtle a', text: 'Add pro').click

      within('.argument-form') do
        fill_in 'argument-title', with: 'Argument title'
        fill_in 'argument-body', with: 'Argument body'
        click_button 'Save'
      end
      fill_in 'opinion-body', with: 'This is my opinion'

      click_button 'Save'
    end
    expect(page).not_to have_content('Would you like to comment on your opinion?')

    visit motion
    expect(page).not_to have_css('.vote-count')
    find('span', text: 'Disagree').click
    within('.opinion-form') do
      expect(page).to have_content('Please confirm your vote by clicking the link we\'ve send to ')
      expect(page).to have_content('This is my opinion')
      expect(page).to have_content('Argument title')
      fill_in 'opinion-body', with: 'This is my new opinion'
      find('label.pro-t').click
      click_button 'Save'
    end

    visit motion
    expect(page).not_to have_css('.vote-count')

    Sidekiq::Testing.inline! do
      visit user_confirmation_path(confirmation_token: User.last.confirmation_token)
    end

    expect(page).to have_content('Choose a password')
    within('form') do
      fill_in 'user_password', with: 'new_password'
      fill_in 'user_password_confirmation', with: 'new_password'
      click_button 'Set password'
    end

    expect(page).to have_content('Your account has been confirmed.')

    visit motion

    expect(page).to have_css('.vote-count')
    within('.opinion-columns') do
      expect(page).to have_content('This is my new opinion')
      expect(page).not_to have_content('Argument title')
    end

    assert_email_sent(skip_sidekiq: true)
  end

  scenario 'Guest should vote and continue with existing email' do
    visit motion
    expect(page).not_to have_content('Comments')
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    # Click a random dropdown to prevent the follow dropdown from interfering
    click_link('Info')
    find('span', text: 'Disagree').click

    Sidekiq::Testing.inline! do
      within('.opinion-form') do
        fill_in 'user[email]', with: user.email
        click_button 'Continue'
      end

      fill_in 'user[password]', with: user.password
      click_button 'Login'
      expect(page).to have_current_path motion.iri_path
    end

    expect(page).to have_css('.btn-con[data-voted-on=true]')
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  scenario 'User should vote on a motion' do
    sign_in(user)

    visit motion
    expect(page).not_to have_content('Comments')
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    # Click a random dropdown to prevent the follow dropdown from interfering
    click_link('Info')
    find('span', text: 'Disagree').click
    expect(page).to have_css('.btn-con[data-voted-on=true]')
    expect(page).to have_css('.opinion-form')

    within('.opinion-form') do
      expect(page).to have_field('opinion-body')

      find('.opinion-form__arguments-selector .box-list-item--subtle a', text: 'Add pro').click

      within('.argument-form') do
        fill_in 'argument-title', with: 'Argument title'
        fill_in 'argument-body', with: 'Argument body'
        click_button 'Save'
      end
      fill_in 'opinion-body', with: 'This is my opinion'

      click_button 'Save'
    end
    expect(page).not_to have_field('opinion-body')

    visit motion
    expect(page).to have_content('Comments')
    within('.opinion-columns') do
      expect(page).to have_content('This is my opinion')
    end

    find('span', text: 'Disagree').click
    within('.opinion-form') do
      find('label.pro-t').click
      click_button 'Save'
    end
    expect(page).not_to have_field('opinion-body')

    visit motion
    expect(page).to have_content('Comments')
    within('.opinion-columns') do
      expect(page).to have_content('This is my opinion')
      expect(page).not_to have_content('Argument title')
    end
  end
end
