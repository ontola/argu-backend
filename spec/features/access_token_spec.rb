require 'rails_helper'

RSpec.feature 'Access tokens', type: :feature do

  let!(:helsinki) { FactoryGirl.create(:hidden_populated_forum,
                                          name: 'helsinki',
                                          visible_with_a_link: true) }
  let(:helsinki_key) { FactoryGirl.create(:access_token, item: helsinki) }

  scenario 'should register and become a member with an access token and preserve vote' do
    visit forum_path(helsinki.url, at: helsinki_key.access_token)
    expect(page).to have_content 'helsinki'

    click_link 'Title2'
    wait_for_ajax

    expect(page).to have_content('content')

    click_link 'Geen van beiden'
    wait_for_modal
    expect(page).to have_content 'REGISTER OR LOG IN'

    click_link 'Create argu account'
    expect(current_path).to eq new_user_registration_path

    user_attr = FactoryGirl.attributes_for(:user)
    within('#new_user') do
      fill_in 'user_email', with: user_attr[:email]
      fill_in 'user_password', with: user_attr[:password]
      fill_in 'user_password_confirmation', with: user_attr[:password]
      click_button 'Sign up'
    end

    expect(current_path).to eq setup_users_path
    click_button 'Volgende'

    profile_attr = FactoryGirl.attributes_for(:profile)
    within('form') do
      fill_in 'profile_profileable_attributes_first_name', with: user_attr[:first_name]
      fill_in 'profile_profileable_attributes_last_name', with: user_attr[:last_name]
      fill_in 'profile_about', with: profile_attr[:about]
      click_button 'Volgende'
    end

    expect(page).to have_content 'Title2'
    expect(page).to have_css 'a.btn-neu[data-voted-on=true]'
  end

end
