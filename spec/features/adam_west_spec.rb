# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Adam west', type: :feature do
  define_page
  let!(:grant_set) do
    grant_set = GrantSet.participator.clone('adam_west_set', argu)
    grant_set.grant_sets_permitted_actions.joins(:permitted_action).where('title LIKE ?', 'comment_%').destroy_all
    grant_set
  end
  define_freetown(attributes: {public_grant: 'adam_west_set'})
  let!(:question) do
    create(:question,
           parent: freetown)
  end
  let!(:motion) do
    create(:motion,
           parent: question)
  end
  let!(:argument) do
    create(:argument,
           parent: motion)
  end
  let(:comment) do
    create :comment,
           parent: argument
  end

  ####################################
  # As Guest
  ####################################
  scenario 'guest should walk from answer up until forum' do
    walk_up_to_forum
  end

  scenario 'guest should visit forum show' do
    visit resource_iri(freetown)

    expect(page).to have_content(freetown.bio)
    expect(page).to have_content(question.display_name)
  end

  scenario 'guest should not see comment section' do
    visit resource_iri(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end

  scenario 'guest should vote on a motion' do
    nominatim_netherlands

    visit motion
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-neutral[data-voted-on=true]')
    find('a', text: 'Other').click

    user_attr = attributes_for(:user)

    Sidekiq::Testing.inline! do
      within('.opinion-form') do
        fill_in 'user[email]', with: user_attr[:email]
        click_button 'Continue'
      end
    end

    expect(page).to have_css('.btn-neutral[data-voted-on=true]')
  end

  scenario 'guest should post a new motion' do
    redirect_url = new_iri(question, :motions)
    create_motion_for_question do
      expect(page).to have_content 'Sign up'

      click_link 'Sign up with email'
      expect(page).to have_current_path new_user_registration_path(r: redirect_url)

      user_attr = attributes_for(:user)

      create_email_mock(
        'confirmation',
        user_attr[:email],
        confirmationToken: /.+/
      )

      within('#new_user') do
        fill_in 'user_email', with: user_attr[:email]
        fill_in 'user_password', with: user_attr[:password]
        fill_in 'user_password_confirmation', with: user_attr[:password]
        click_button 'Sign up'
      end

      setup_profile(user_attr)
    end

    assert_email_sent
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

    visit resource_iri(freetown)

    expect(page).to have_content(freetown.bio)
    expect(page).to have_content(question.display_name)
  end

  scenario 'user should not see comment section' do
    sign_in(user)

    visit resource_iri(argument)

    expect(page).not_to have_content('Reply')
    expect(page).not_to have_content('Comments')
  end

  scenario 'user should vote on a motion' do
    sign_in(user)

    visit motion
    expect(page).to have_content(motion.content)
    expect(page).not_to have_content('New discussion')

    expect(page).not_to have_css('.btn-pro[data-voted-on=true]')
    find('.btn-pro').click
    expect(page).to have_content(motion.display_name)
    expect(page).to have_css('.btn-pro[data-voted-on=true]')

    visit motion
    expect(page).to have_css('.btn-pro[data-voted-on=true]')
  end

  scenario 'user should post a new motion' do
    sign_in(user)

    create_motion_for_question
  end

  ####################################
  # As Moderator
  ####################################
  let(:moderator) { create_moderator(freetown) }

  scenario 'moderator should walk from answer up until forum' do
    sign_in(moderator)

    walk_up_to_forum moderator
    expect(page).to have_content('New discussion')
  end

  scenario 'moderator should visit forum show' do
    sign_in(moderator)

    visit resource_iri(freetown)

    expect(page).to have_content(freetown.display_name)
    expect(page).to have_content(freetown.bio)
    expect(page).to have_current_path(resource_iri(freetown).path)
  end

  scenario 'moderator should see comment section' do
    sign_in(moderator)

    visit resource_iri(argument)

    expect(page.body).to have_content('Reply')
  end

  scenario 'moderator should see motion new button' do
    sign_in(moderator)

    visit question

    expect(page).to have_content('Share your idea')
  end

  private

  def create_motion_for_question # rubocop:disable Metrics/AbcSize
    visit question
    click_on 'Share your idea'

    yield if block_given?

    motion_attr = attributes_for(:motion)
    within('#new_motion') do
      fill_in 'motion[display_name]', with: motion_attr[:title]
      fill_in 'motion[description]', with: motion_attr[:content]
      click_button 'Save'
    end

    expect(page).to have_content(motion_attr[:title].capitalize)
    expect(page).to have_current_path("#{Motion.last.iri.path}?start_motion_tour=true")
    press_key :escape
    click_on question.title
    expect(page).to have_current_path(resource_iri(question))
    expect(page).to have_content(question.content)
  end

  def setup_profile(user_attr) # rubocop:disable Metrics/AbcSize
    nominatim_netherlands

    expect(page).to have_current_path setup_users_path

    within('form.formtastic') do
      fill_in 'user_first_name', with: user_attr[:first_name]
      fill_in 'user_last_name', with: user_attr[:last_name]
      click_button 'Next'
    end

    profile_attr = attributes_for(:profile)
    within('form.formtastic') do
      fill_in 'user_profile_attributes_about', with: profile_attr[:about]
      click_button 'Save'
    end
  end

  def walk_up_to_forum(role = nil) # rubocop:disable Metrics/AbcSize
    visit resource_iri(argument)
    expect(page).to have_css("img[src*='#{role.profile.default_profile_photo.url(:icon)}']") if role.present?
    expect(page).to have_content(argument.title)
    expect(page).to have_content(argument.content)

    click_link motion.title
    expect(page).to have_current_path resource_iri(motion).path
    expect(page).to have_content(motion.title)
    expect(page).to have_content(motion.content)

    click_link question.title
    expect(page).to have_current_path resource_iri(question).path
    expect(page).to have_content(question.title)
    expect(page).to have_content(question.content)

    within('.wrapper') do
      click_link freetown.display_name
    end
    expect(page).to have_current_path resource_iri(freetown).path
    expect(page).to have_content(freetown.display_name)
    expect(page).to have_content(question.display_name)
  end
end
