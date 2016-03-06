require 'rails_helper'

RSpec.feature 'Voting', type: :feature do

  let(:freetown) { create(:forum, name: 'freetown') }
  let(:motion) do
    create(:motion,
           forum: freetown)
  end

  ####################################
  # As Guest
  ####################################

  scenario 'Guest should vote on a motion' do
    visit motion_path(motion)
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('span span', text: "DISAGREE").click
    expect(page).to have_content 'Sign up'

    click_link 'Sign up with email'
    expect(current_path).to eq new_user_registration_path

    user_attr = FactoryGirl.attributes_for(:user)
    within('#new_user') do
      fill_in 'user_email', with: user_attr[:email]
      fill_in 'user_password', with: user_attr[:password]
      fill_in 'user_password_confirmation', with: user_attr[:password]
      click_button 'Sign up'
    end

    expect(current_path).to eq setup_users_path
    click_button 'Next'

    profile_attr = FactoryGirl.attributes_for(:profile)
    within('form') do
      fill_in 'profile_profileable_attributes_first_name', with: user_attr[:first_name]
      fill_in 'profile_profileable_attributes_last_name', with: user_attr[:last_name]
      fill_in 'profile_about', with: profile_attr[:about]
      click_button 'Next'
    end

    click_button 'Disagree'

    expect(current_path).to eq(motion_path(motion))
    expect(page).to have_css('.btn-con[data-voted-on=true]')
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  scenario 'User should vote on a motion' do
    login_as(user)

    visit motion_path(motion)
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('span span', text: "DISAGREE").click
    expect(page).to have_css('.btn-con[data-voted-on=true]')

    visit motion_path(motion)
    expect(page).to have_css('.btn-con[data-voted-on=true]')
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  scenario 'Member should vote on a motion' do
    login_as(member)

    visit motion_path(motion)
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('span span', text: "DISAGREE").click
    expect(page).to have_css('.btn-con[data-voted-on=true]')

    visit motion_path(motion)
    expect(page).to have_css('.btn-con[data-voted-on=true]')
  end

end
