# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Announcements', type: :feature do
  define_holland
  let!(:unpublished_announcement) do
    create(:announcement,
           :unpublished,
           :everyone,
           title: 'unpublished_announcement')
  end

  %i[guests users everyone].each do |audience|
    let!("announcement_#{audience}".to_sym) do
      create(:announcement,
             :published,
             audience,
             content: "Announcement_#{audience}")
    end
  end

  ####################################
  # As Guest
  ####################################
  scenario 'All objects show announcements' do
    question = holland.questions.first
    visit question
    expect(page).to have_content(question.title)
    expect(page).to have_content(announcement_everyone.content)
    expect(page).not_to have_content(unpublished_announcement.content),
                        'Announcements not visible on question pages'

    motion = holland.motions.first
    visit motion
    expect(page).to have_content(motion.content)
    expect(page).to have_content(announcement_everyone.content),
                    'Announcements not visible on motion pages'

    argument = holland.motions.first.arguments.first
    visit argument
    expect(page).to have_content(argument.content)
    expect(page).to have_content(announcement_everyone.content),
                    'Announcements not visible on argument pages'
  end

  scenario 'Guest sees correct announcements' do
    question = holland.questions.first

    visit question
    expect(page).to have_content(question.title)

    expect(page).to have_content(announcement_everyone.content),
                    "Guest doesn't see everyone announcements"
    expect(page).to have_content(announcement_guests.content),
                    "Guest doesn't see guests announcements"
    expect(page).not_to have_content(announcement_users.content),
                        'Guest sees user announcements'
  end

  scenario 'Guest dismisses an announcement' do
    question = holland.questions.first
    visit question

    expect(page).to have_content(question.title)
    expect(page).to have_content(announcement_guests.content)
    within("##{announcement_guests.identifier}") do
      page.find('.box-close-button').click
    end
    expect(page).to_not have_content(announcement_guests.content)

    visit question
    expect(page).to_not have_content(announcement_guests.content)
    expect(page).to have_content(announcement_everyone.content)
  end

  ####################################
  # As User
  ####################################
  scenario 'User sees correct announcements' do
    sign_in(FactoryBot.create(:user))
    question = holland.questions.first
    visit question
    expect(page).to have_content(question.title),
                    'page not loaded correctly to run expectations'

    expect(page).to have_content(announcement_everyone.content),
                    "User doesn't see everyone announcements"
    expect(page).not_to have_content(announcement_guests.content),
                        'User sees guests announcements'
    expect(page).to have_content(announcement_users.content),
                    "User doesn't see users announcements"
  end

  scenario 'announcement dismissal is persisted across logins' do
    user = FactoryBot.create(:user)
    sign_in_manually(user, redirect_to: resource_iri(holland).path)
    question = holland.questions.first
    visit question

    expect(page).to have_content(question.title)
    expect(page).to have_content(announcement_users.content)
    within("##{announcement_users.identifier}") do
      page.find('.box-close-button').click
    end
    expect(page).to_not have_content(announcement_users.content)
    clear_cookies

    visit question
    expect(page).to_not have_content(announcement_users.content)
    expect(page).to have_content(announcement_everyone.content)

    clear_cookies
    visit question
    expect(page).to have_content(announcement_guests.content)
    expect(page).to have_content(announcement_everyone.content)

    sign_in_manually(user, redirect_to: resource_iri(holland).path)
    visit question
    expect(page).to_not have_content('Log in')
    expect(page).to_not have_content(announcement_users.content)
    expect(page).to have_content(announcement_everyone.content)
  end
end
