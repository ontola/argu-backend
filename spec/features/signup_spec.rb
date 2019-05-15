# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Signup', type: :feature do
  include ApplicationHelper
  include UsersHelper
  let!(:default_forum) { create(:setting, key: 'default_forum', value: default.uuid) }
  define_freetown('default', attributes: {name: 'default'})
  define_freetown(attributes: {name: 'freetown'})
  let!(:motion) { create(:motion, parent: freetown) }
  let(:netherlands) { create(:place, address: {'country_code' => 'nl'}) }

  scenario 'should register w/ oauth and preserve vote on non-default forum' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash

    visit root_path
    expect(page).to have_content 'Make better decisions'
    expect(page).to have_current_path root_path

    visit resource_iri(freetown)
    expect(page).to have_content 'freetown'

    click_link motion.title
    expect(page).to have_content(motion.content)

    assert_difference 'Argu::Redis.keys("temporary*").count', 1 do
      click_link 'Other'
      expect(page).to have_css 'a.btn-neutral[data-voted-on=true]'
    end

    assert_difference 'User.count' => 1, 'Favorite.count' => 1, 'Vote.count' => 1 do
      Sidekiq::Testing.inline! do
        within('.opinion-form') do
          click_link 'Log in with Facebook'
        end
        expect(page).to have_content 'Succesfully connected to a Facebook account'
        expect(page).to have_current_path resource_iri(motion).path
        expect(page).to have_content motion.title
        expect(page).to have_css 'a.btn-neutral[data-voted-on=true]'
      end
    end
  end

  scenario 'should register w/ oauth and connect account' do
    OmniAuth.config.mock_auth[:facebook] = facebook_auth_hash
    facebook_me
    facebook_me(fields: {name: 'My Name'})
    u = create(:user, email: 'bpvjlwt_zuckersen_1467905538@tfbnw.net')

    visit motion
    expect(page).to have_content(motion.content)

    click_link 'Other'
    Sidekiq::Testing.inline! do
      within('.opinion-form') do
        click_link 'Log in with Facebook'
      end
      expect(page).to have_current_path(connect_user_path(u), ignore_query: true)

      fill_in 'Argu password', with: 'password'
      click_button 'Save'

      expect(page).to have_content('Account connected')
      expect(u.reload.identities.count).to eq(1)
    end

    visit motion

    expect(page).to have_content motion.title
    expect(page).to have_css 'a.btn-neutral[data-voted-on=true]'
  end

  scenario 'should register with country only' do
    netherlands

    visit new_user_session_path

    click_link 'Sign up with email'

    user_attrs = attributes_for(:user)

    create_email_mock(
      'confirmation',
      user_attrs[:email],
      confirmationToken: /.+/
    )

    expect(page).not_to have_content('Sign up with email')
    within('#new_user') do
      fill_in 'user_email', with: user_attrs[:email]
      fill_in 'user_password', with: user_attrs[:password]
      fill_in 'user_password_confirmation', with: user_attrs[:password_confirmation]
      click_button 'Sign up'
    end

    expect(page).to have_current_path setup_users_path
    within('.formtastic.user') do
      click_button 'Next'
    end

    fill_in_select '#user_home_placement_attributes_country_code_input',
                   with: 'Netherlands',
                   selector: /Netherlands$/
    click_button 'Save'

    expect(page).to have_current_path(resource_iri(User.last, root: argu).path)
    expect(User.last.country).to eq('NL')
    assert_email_sent
  end
end
