require 'rails_helper'

RSpec.feature 'Banners', type: :feature do
  let!(:holland) do
    FactoryGirl.create(:populated_forum,
                       name: 'holland')
  end
  let!(:unpublished_banner) do
    FactoryGirl.create(:banner,
                       :unpublished,
                       :everyone,
                       forum: holland,
                       title: 'unpublished_banner')
  end

  %i(guests users members everyone).each do |audience|
    let!("banner_#{audience}".to_sym) do
      FactoryGirl.create(:banner,
                         :published,
                         audience,
                         forum: holland,
                         title: "banner_#{audience}")
    end
  end

  scenario 'All objects show banners' do
    question = holland.questions.first
    visit question_path question
    expect(page).to have_content(question.title)
    expect(page).to have_content(banner_everyone.title)
    expect(page).not_to have_content(unpublished_banner.title),
                        'Banners not visible on question pages'

    motion = holland.motions.first
    visit motion_path motion
    expect(page).to have_content(motion.title)
    expect(page).to have_content(banner_everyone.title),
                    'Banners not visible on motion pages'

    argument = holland.motions.first.arguments.first
    visit argument_path argument
    expect(page).to have_content(argument.title)
    expect(page).to have_content(banner_everyone.title),
                    'Banners not visible on argument pages'
  end

  ####################################
  # As Guest
  ####################################
  scenario 'Guest sees correct banners' do
    question = holland.questions.first

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
  end

  ####################################
  # As User
  ####################################
  scenario 'User sees correct banners' do
    login_as(FactoryGirl.create(:user), scope: :user)
    question = holland.questions.first
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
  end

  ####################################
  # As Member
  ####################################
  scenario 'Member sees everyone banners' do
    user = create_member(holland)
    login_as(user, scope: :user)
    question = holland.questions.first
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
  end
end
