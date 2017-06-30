# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Banners', type: :feature do
  define_spain
  let!(:unpublished_banner) do
    create(:banner,
           audience: Banner.audiences[:everyone],
           forum: spain,
           title: 'unpublished_banner')
  end

  let!(:ended_banner) do
    create(:banner,
           ends_at: 1.hour.ago,
           audience: Banner.audiences[:everyone],
           published_at: 1.hour.ago,
           forum: spain,
           title: 'ended_banner')
  end

  %i(guests users members everyone).each do |audience|
    let!("banner_#{audience}".to_sym) do
      create(:banner,
             published_at: 1.hour.ago,
             audience: Banner.audiences[audience],
             forum: spain,
             title: "Banner_#{audience}")
    end
  end

  ####################################
  # As Guest
  ####################################
  scenario 'All objects show banners' do
    question = spain.questions.first
    visit question_path question
    expect(page).to have_content(question.title)
    expect(page).to have_content(banner_everyone.title),
                    'Everyone banners not visible on question pages'
    expect(page).not_to have_content(unpublished_banner.title),
                        'Unpublished visible on question pages'
    expect(page).not_to have_content(ended_banner.title),
                        'Ended visible on question pages'

    motion = spain.motions.first
    visit motion_path motion
    expect(page).to have_content(motion.title)
    expect(page).to have_content(banner_everyone.title),
                    'Banners not visible on motion pages'

    argument = spain.motions.first.arguments.first
    visit argument_path(argument)
    expect(page).to have_content(argument.title)
    expect(page).to have_content(banner_everyone.title),
                    'Banners not visible on argument pages'
  end

  scenario 'Guest sees correct banners' do
    question = spain.questions.first

    visit question_path question
    expect(page).to have_content(question.title)

    expect(page).to have_content(banner_everyone.title),
                    "Guest doesn't see everyone banners"
    expect(page).to have_content(banner_guests.title),
                    "Guest doesn't see guests banners"
    expect(page).not_to have_content(banner_users.title),
                        'Guest sees user banners'
    expect(page).not_to have_content(banner_members.title),
                        'Guest sees member banners'
    expect(page).not_to have_content(unpublished_banner.title),
                        'Unpublished visible for guests'
    expect(page).not_to have_content(ended_banner.title),
                        'Ended visible for guests'
  end

  scenario 'Guest dismisses a banner' do
    question = spain.questions.first
    visit question_path(question)

    expect(page).to have_content(question.title)
    expect(page).to have_content(banner_guests.title)
    within("##{banner_guests.identifier}") do
      page.find('.box-close-button').click
    end
    expect(page).to_not have_content(banner_guests.title)

    visit question_path(question)
    expect(page).to have_content(question.content)
    expect(page).to_not have_content(banner_guests.title)
    expect(page).to have_content(banner_everyone.title)
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  scenario 'User sees correct banners' do
    sign_in_manually(user)
    question = spain.questions.first
    visit question_path question
    expect(page).to have_content(question.title),
                    'page not loaded correctly to run expectations'

    expect(page).to have_content(banner_everyone.title),
                    "User doesn't see everyone banners"
    expect(page).not_to have_content(banner_guests.title),
                        'User sees guests banners'
    expect(page).to have_content(banner_users.title),
                    "User doesn't see users banners"
    expect(page).not_to have_content(banner_members.title),
                        'User sees members banners'
    expect(page).not_to have_content(unpublished_banner.title),
                        'Unpublished visible for users'
    expect(page).not_to have_content(ended_banner.title),
                        'Ended visible for users'
  end

  scenario 'banner dismissal is persisted across logins' do
    sign_in_manually(user)
    question = spain.questions.first
    visit question_path(question)

    expect(page).to have_content(question.title)
    expect(page).to have_content(banner_users.title)
    within("##{banner_users.identifier}") do
      page.find('.box-close-button').click
    end
    expect(page).to_not have_content(banner_users.title)
    logout(:user)

    visit question_path(question)
    expect(page).to_not have_content(banner_users.title)
    expect(page).to have_content(banner_everyone.title)

    clear_cookies
    visit question_path(question)
    expect(page).to have_content(banner_guests.title)
    expect(page).to have_content(banner_everyone.title)

    sign_in_manually(user)
    visit question_path(question)
    expect(page).to_not have_content('Log in')
    expect(page).to_not have_content(banner_users.title)
    expect(page).to have_content(banner_everyone.title)
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(spain) }

  scenario 'Member sees everyone banners' do
    sign_in(member)
    question = spain.questions.first
    visit question_path question
    expect(page).to have_content(question.title),
                    'page not loaded correctly to run expectations'

    expect(page).to have_content(banner_everyone.title),
                    "Member doesn't see everyone banners"
    expect(page).not_to have_content(banner_guests.title),
                        'Member sees guests banners'
    expect(page).not_to have_content(banner_users.title),
                        'Member sees users banners'
    expect(page).to have_content(banner_members.title),
                    "Member doesn't see members banners"
    expect(page).not_to have_content(unpublished_banner.title),
                        'Unpublished visible for members'
    expect(page).not_to have_content(ended_banner.title),
                        'Ended visible for members'
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create(:user, :staff) }

  scenario 'Staff creates a banner' do
    sign_in(staff)

    new_banner = attributes_for(:banner, :everyone)

    visit settings_forum_path(spain, tab: :banners)
    click_link 'New banner'

    expect(page).to have_content('New Banner')
    within('#new_banner') do
      fill_in :banner_title, with: new_banner[:title]
      fill_in :banner_content, with: new_banner[:content]
      select 'Everyone', from: :banner_audience
      click_button 'Create Banner'
    end
    expect(page).to have_content 'Banner saved successfully'
    within('#banners-drafts') do
      expect(page).to have_content(new_banner[:title])
    end
  end

  scenario 'Staff views banner settings' do
    sign_in(staff)

    visit settings_forum_path(spain, tab: :banners)
    within('#banners-published') do
      %i(guests users members everyone).each do |level|
        expect(page).to have_content(send("banner_#{level}").title)
      end
    end
    within('#banners-drafts') do
      expect(page).to have_content(unpublished_banner.title)
    end
    within('#banners-ended') do
      expect(page).to have_content(ended_banner.title)
    end
  end
end
