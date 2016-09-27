# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Login', type: :feature do
  define_holland
  let!(:holland_member) { create_member(holland) }
  let(:user) { create(:user_with_votes) }

  scenario 'User logs in from a Forum' do
    visit(forum_path('holland'))
    expect(page).to have_current_path forum_path('holland')
    click_link('sign_in')
    expect do
      within('#new_user') do
        fill_in 'user_email', with: holland_member.email
        fill_in 'user_password', with: 'password'
        click_button 'log_in'
      end
      expect(page).to have_current_path forum_path('holland')
    end.to change { Doorkeeper::AccessToken.count }.by(1)
  end

  scenario 'User logs in from a profile' do
    visit(user_path(user))
    expect(page).to have_content('Neutral')
    click_link('sign_in')
    expect do
      within('#new_user') do
        fill_in 'user_email', with: holland_member.email
        fill_in 'user_password', with: 'password'
        click_button 'log_in'
      end
      expect(page).to have_current_path user_path(user)
    end.to change { Doorkeeper::AccessToken.count }.by(1)
  end
end
