# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Comments', type: :feature do
  define_freetown('holland')
  let!(:motion) { create(:motion, parent: holland.edge) }
  let!(:argument) { create(:argument, parent: motion.edge) }
  let!(:blog_post) do
    create(:blog_post,
           argu_publication: build(:publication),
           happening_attributes: {happened_at: DateTime.current},
           parent: motion.edge)
  end

  ####################################
  # As guest
  ####################################
  scenario 'Guest places a comment for an argument and signs up' do
    nominatim_netherlands

    visit argument_path(argument)

    fill_in_and_submit_comment

    sign_up_and_confirm_comment

    expect(page).to have_content argument.title
  end

  scenario 'Guest places a comment for a blog_post and signs up' do
    nominatim_netherlands

    visit blog_post_path(blog_post)

    fill_in_and_submit_comment

    sign_up_and_confirm_comment

    expect(page).to have_content blog_post.title
  end

  ####################################
  # As user
  ####################################
  let(:user) { create(:user) }

  scenario 'User places nested comments' do
    login_as(user, scope: :user)
    visit argument_path(argument)

    fill_in_and_submit_comment

    click_button 'Reply'

    expect(page).to have_content argument.title
    expect(page).to have_content comment_args[:body]

    within("#comments_#{Comment.last.id}") do
      click_link 'Reply'
    end

    within("#cf#{Comment.last.id}") do
      expect(page).to have_field('comment[body]')
      fill_in 'comment[body]', with: comment_args[:body]
      click_button 'Reply'
    end
  end

  ####################################
  # As member
  ####################################
  let(:member) { create_member(holland) }

  scenario 'Member places a comment' do
    login_as(member, scope: :user)
    visit argument_path(argument)

    fill_in_and_submit_comment

    expect(page).to have_content argument.title
    expect(page).to have_content comment_args[:body]
  end

  private

  def comment_args
    @comment_args ||= attributes_for(:comment)
  end

  def fill_in_and_submit_comment
    within('#cf') do
      expect(page).to have_field('comment[body]')
      fill_in 'comment[body]', with: comment_args[:body]
      click_button 'Reply'
    end
  end

  def sign_up_and_confirm_comment
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

    within('.formtastic.user') do
      click_button 'Next'
    end

    within('#comment_submit_action') do
      click_button 'Reply'
    end

    expect(page).to have_content comment_args[:body]
  end
end
