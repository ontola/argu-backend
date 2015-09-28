require 'rails_helper'

RSpec.feature 'Comments', type: :feature do

  let!(:holland) { FactoryGirl.create(:populated_forum, name: 'holland') }
  let!(:argument) { FactoryGirl.create(:argument, forum: holland) }

  ####################################
  # As guest
  ####################################

  scenario 'Guest places a comment and signs up' do
    visit argument_path(argument)

    comment_args = attributes_for(:comment)
    within('#cf') do
      expect(page).to have_field('comment[body]')
      fill_in 'comment[body]', with: comment_args[:body]
      click_button 'Reply'
    end

    click_link 'Create Argu account'
    user_attr = attributes_for(:user)
    within('#new_user') do
      fill_in 'user[email]', with: user_attr[:email]
      fill_in 'user[password]', with: user_attr[:password]
      fill_in 'user[password_confirmation]', with: user_attr[:password]
      click_button 'Sign up'
    end

    within('#user_submit_action') do
      click_button 'Volgende'
    end

    within('.formtastic.profile') do
      click_button 'Volgende'
    end

    expect(page).to have_content argument.title
    within('#comment_submit_action') do
      click_button 'Reageer'
    end

    expect(page).to have_content argument.title
    expect(page).to have_content comment_args[:body]
  end

  ####################################
  # As user
  ####################################
  let!(:user) { FactoryGirl.create(:user) }

  scenario 'User places a comment' do
    login_as(user, :scope => :user)
    visit argument_path(argument)

    comment_args = attributes_for(:comment)
    within('#cf') do
      expect(page).to have_field('comment[body]')
      fill_in 'comment[body]', with: comment_args[:body]
      click_button 'Reageer'
    end
    expect(page).to have_content ' toe aan jouw forums en doe mee aan de discussie!'
    find('.modal').click_link('join-forum')

    expect(page).to have_content argument.title
    expect(page).to have_content comment_args[:body]
  end

  ####################################
  # As member
  ####################################
  let!(:member) { create_member(holland) }

  scenario 'Member places a comment' do
    login_as(member, :scope => :user)
    visit argument_path(argument)

    comment_args = attributes_for(:comment)
    within('#cf') do
      expect(page).to have_field('comment[body]')
      fill_in 'comment[body]', with: comment_args[:body]
      click_button 'Reageer'
    end

    expect(page).to have_content argument.title
    expect(page).to have_content comment_args[:body]
  end

end
