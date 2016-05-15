require 'rails_helper'

RSpec.feature 'Comments', type: :feature do
  define_common_objects :user, member: {forum: :holland},
                        forum: [:populated, var_name: :holland, name: 'holland'],
                        argument!: {forum: :holland}

  ####################################
  # As Guest
  ####################################
  scenario 'Guest places a comment and signs up' do
    nominatim_netherlands

    visit argument_path(argument)

    comment_args = attributes_for(:comment)
    within('#cf') do
      expect(page).to have_field('comment[body]')
      fill_in 'comment[body]', with: comment_args[:body]
      click_button 'Reply'
    end

    click_link 'Sign up with email'
    user_attr = attributes_for(:user)
    within('#new_user') do
      fill_in 'user[email]', with: user_attr[:email]
      fill_in 'user[password]', with: user_attr[:password]
      fill_in 'user[password_confirmation]', with: user_attr[:password]
      click_button 'Sign up'
    end

    within('#user_submit_action') do
      click_button 'Next'
    end

    within('.formtastic.profile') do
      click_button 'Next'
    end

    expect(page).to have_content argument.title
    within('#comment_submit_action') do
      click_button 'Reply'
    end

    expect(page).to have_content argument.title
    expect(page).to have_content comment_args[:body]
  end

  ####################################
  # As User
  ####################################
  scenario 'User places a comment' do
    sign_in(user)
    visit argument_path(argument)

    comment_args = attributes_for(:comment)
    within('#cf') do
      expect(page).to have_field('comment[body]')
      fill_in 'comment[body]', with: comment_args[:body]
      click_button 'Reply'
    end
    expect(page).to have_content 'and participate in the discussion!'
    find('.modal').click_link('join-forum')

    expect(page).to have_content argument.title
    expect(page).to have_content comment_args[:body]
  end

  ####################################
  # As Member
  ####################################
  scenario 'Member places a comment' do
    sign_in(member)
    visit argument_path(argument)

    comment_args = attributes_for(:comment)
    within('#cf') do
      expect(page).to have_field('comment[body]')
      fill_in 'comment[body]', with: comment_args[:body]
      click_button 'Reply'
    end

    expect(page).to have_content argument.title
    expect(page).to have_content comment_args[:body]
  end
end
