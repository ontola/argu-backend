require 'rails_helper'

RSpec.feature 'Login', type: :feature do
  define_common_objects forum!: [:populated, var_name: :holland, name: 'holland'],
                        member!: {forum: :holland}
  let(:user) { create(:user_with_votes) }

  scenario 'User logs in from a Forum' do
    visit(forum_path('holland'))
    expect(page).to have_current_path forum_path('holland')
    click_link('sign_in')
    within('#new_user') do
      fill_in 'user_email', with: member.email
      fill_in 'user_password', with: 'password'
      click_button 'log_in'
    end

    expect(page).to have_content 'Welcome back!'
    expect(page).to have_current_path forum_path('holland')
  end

  scenario 'User logs in from a profile' do
    visit(user_path(user))
    expect(page).to have_content('Neutral')
    click_link('sign_in')
    within('#new_user') do
      fill_in 'user_email', with: member.email
      fill_in 'user_password', with: 'password'
      click_button 'log_in'
    end

    expect(page).to have_content 'Welcome back!'
    expect(page).to have_current_path user_path(user)
  end
end
