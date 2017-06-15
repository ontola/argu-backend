# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Adam west', type: :feature do
  let!(:default_forum) { create(:setting, key: 'default_forum', value: 'default') }
  define_freetown('default', attributes: {name: 'default'})
  define_freetown
  let!(:f_rule_c) do
    %w(show? create?).each do |action|
      create(:rule,
             branch: freetown.edge,
             model_type: 'Comment',
             model_id: nil,
             action: action,
             role: 'manager',
             permit: false)
    end
  end
  let!(:f_rule_q_c) do
    create(:rule,
           branch: freetown.edge,
           model_type: 'Question',
           model_id: nil,
           action: :create?,
           role: 'member',
           permit: false)
  end
  let!(:f_rule_m_ncwwoq) do
    create(:rule,
           branch: freetown.edge,
           model_type: 'Motion',
           model_id: nil,
           action: :create_without_question?,
           role: 'member',
           permit: false)
  end
  let!(:question) do
    create(:question,
           parent: freetown.edge)
  end
  let!(:motion) do
    create(:motion,
           parent: question.edge)
  end
  let!(:argument) do
    create(:argument,
           parent: motion.edge)
  end
  let(:comment) do
    create :comment,
           parent: argument.edge
  end

  ####################################
  # As Guest
  ####################################
  scenario 'guest should walk from answer up until forum' do
    walk_up_to_forum
  end

  scenario 'guest should visit forum show' do
    visit forum_path(freetown)

    expect(page).to have_content(freetown.bio)
    expect(page).to have_content(question.display_name)
  end

  scenario 'guest should not see comment section' do
    visit argument_path(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end

  scenario 'guest should vote on a motion' do
    nominatim_netherlands

    visit motion_path(motion)
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-neutral[data-voted-on=true]')
    find('a', text: 'Neutral').click

    user_attr = attributes_for(:user)

    Sidekiq::Testing.inline! do
      within('.opinion-form') do
        fill_in 'user[email]', with: user_attr[:email]
        click_button 'Save'
      end

      setup_profile(user_attr)
    end

    expect(page).to have_css('.btn-neutral[data-voted-on=true]')
  end

  scenario 'guest should post a new motion' do
    redirect_url = new_question_motion_path(question_id: question)
    create_motion_for_question do
      expect(page).to have_content 'Sign up'

      click_link 'Sign up with email'
      expect(page).to have_current_path new_user_registration_path(r: redirect_url)

      user_attr = attributes_for(:user)
      within('#new_user') do
        fill_in 'user_email', with: user_attr[:email]
        fill_in 'user_password', with: user_attr[:password]
        fill_in 'user_password_confirmation', with: user_attr[:password]
        click_button 'Sign up'
      end

      setup_profile(user_attr)
    end
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  scenario 'user should walk from answer up until forum' do
    sign_in(user)

    walk_up_to_forum user
    expect(page).not_to have_content('New discussion')
  end

  scenario 'user should visit forum show' do
    sign_in(user)

    visit forum_path(freetown)

    expect(page).to have_content(freetown.bio)
    expect(page).to have_content(question.display_name)
  end

  scenario 'user should not see comment section' do
    sign_in(user)

    visit argument_path(argument)

    expect(page).not_to have_content('Reply')
    expect(page).not_to have_content('Comments')
  end

  scenario 'user should vote on a motion' do
    sign_in(user)

    visit motion_path(motion)
    expect(page).to have_content(motion.content)
    expect(page).not_to have_content('New discussion')

    expect(page).not_to have_css('.btn-pro[data-voted-on=true]')
    find('.btn-pro').click
    expect(page).to have_content(motion.display_name)
    expect(page).to have_css('.btn-pro[data-voted-on=true]')

    visit motion_path(motion)
    expect(page).to have_css('.btn-pro[data-voted-on=true]')
  end

  scenario 'user should post a new motion' do
    sign_in(user)

    create_motion_for_question
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  scenario 'member should walk from answer up until forum' do
    sign_in(member)

    walk_up_to_forum member
    expect(page).not_to have_content('New discussion')
  end

  scenario 'member should visit forum show' do
    sign_in(member)

    visit forum_path(freetown)

    expect(page).to have_content(freetown.bio)
    expect(page).to have_content(question.display_name)
  end

  scenario 'member should not see comment section' do
    sign_in(member)

    visit argument_path(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end

  scenario 'member should not see top comment' do
    sign_in(member)

    visit motion_path(motion)

    expect(page).to have_content(argument.title)
    expect(page).not_to have_content(comment.body)
    expect(page.body).not_to have_content('Reply')

    # Anti-test
    arg = create(:argument, parent: create(:motion, parent: default.edge).edge)

    visit motion_path(arg.parent_model)

    expect(page).to have_content(arg.title)
    expect(page.body).to have_content('Reply')

    c = create(:comment,
               parent: arg.edge)

    visit motion_path(arg.parent_model)
    expect(page).to have_content(arg.title)
    expect(page).to have_content(c.body)
  end

  scenario 'member should not post create comment' do
    sign_in(member)

    visit argument_path(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end

  scenario 'member should vote on a motion' do
    nominatim_netherlands

    sign_in(member)

    visit motion_path(motion)
    expect(page).to have_content(motion.content)
    expect(page).not_to have_content('New discussion')

    expect(page).not_to have_css('.btn-pro[data-voted-on=true]')
    find('.btn-pro').click
    expect(page).to have_css('.btn-pro[data-voted-on=true]')

    visit motion_path(motion)
    expect(page).to have_css('.btn-pro[data-voted-on=true]')
  end

  scenario 'member should post a new motion' do
    sign_in(member)

    create_motion_for_question
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager(freetown) }

  scenario 'manager should walk from answer up until forum' do
    sign_in(manager)

    walk_up_to_forum manager
    expect(page).to have_content('New discussion')
  end

  scenario 'manager should visit forum show' do
    sign_in(manager)

    visit forum_path(freetown)

    expect(page).to have_content(freetown.display_name)
    expect(page).to have_content(freetown.bio)
    expect(page).to have_current_path(forum_path(freetown))
  end

  scenario 'manager should not see comment section' do
    sign_in(manager)

    visit argument_path(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end

  scenario 'manager should see motion new button' do
    sign_in(manager)

    visit question_path(question)

    expect(page).to have_content('Share your idea')
  end

  private

  def create_motion_for_question
    visit question_path(question)
    click_on 'Share your idea'

    yield if block_given?

    motion_attr = attributes_for(:motion)
    within('#new_motion') do
      fill_in 'motion[title]', with: motion_attr[:title]
      fill_in 'motion[content]', with: motion_attr[:content]
      click_button 'Save'
    end

    expect(page).to have_content(motion_attr[:title].capitalize)
    expect(page).to have_current_path(motion_path(Motion.last, start_motion_tour: true))
    press_key :escape
    click_on question.title
    expect(page).to have_current_path(question_path(question))
    expect(page).to have_content(question.content)
  end

  def setup_profile(user_attr)
    nominatim_netherlands

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

  def walk_up_to_forum(role = nil)
    visit argument_path(argument)
    expect(page).to have_css("img[src*='#{role.profile.default_profile_photo.url(:icon)}']") if role.present?
    expect(page).to have_content(argument.title)
    expect(page).to have_content(argument.content)

    click_link motion.title
    expect(page).to have_current_path motion_path(motion)
    expect(page).to have_content(motion.title)
    expect(page).to have_content(motion.content)

    click_link question.title
    expect(page).to have_current_path question_path(question)
    expect(page).to have_content(question.title)
    expect(page).to have_content(question.content)

    within('.wrapper') do
      click_link freetown.display_name
    end
    expect(page).to have_current_path forum_path(freetown)
    expect(page).to have_content(freetown.display_name)
    expect(page).to have_content(question.display_name)
  end
end
