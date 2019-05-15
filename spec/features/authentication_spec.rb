# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Authentication', type: :feature do
  include ActionView::Helpers::TextHelper

  define_holland
  let!(:holland_initiator) { create_initiator(holland) }
  let(:user) { create(:user_with_votes) }

  let(:omniauth_user) do
    user_fb_only = create(
      :user,
      :no_password,
      email: 'user_fb_only@argu.co',
      first_name: 'First',
      last_name: 'Lastname_facebook',
      confirmed_at: Time.current
    )
    create(
      :identity,
      provider: :facebook,
      uid: 102_555_400_181_774,
      user: user_fb_only
    )
    hash = facebook_auth_hash(
      email: user_fb_only.email,
      name: "#{user_fb_only.first_name} #{user_fb_only.last_name}"
    )
    OmniAuth.config.mock_auth[:facebook] = hash
    facebook_me(token: hash.dig(:credentials, :token))
  end

  describe 'login' do
    describe 'with credentials' do
      scenario 'from a Forum' do
        visit(resource_iri(holland))
        expect(page).to have_current_path resource_iri(holland).path
        click_link('sign_in')
        expect do
          within('#new_user') do
            fill_in 'user_email', with: holland_initiator.email
            fill_in 'user_password', with: 'password'
            click_button 'log_in'
          end
          expect(page).to have_current_path resource_iri(holland).path
        end.to change { Doorkeeper::AccessToken.count }.by(1)
      end

      scenario 'from a profile' do
        visit(user.iri)
        click_link('sign_in')
        expect do
          within('#new_user') do
            fill_in 'user_email', with: holland_initiator.email
            fill_in 'user_password', with: 'password'
            click_button 'log_in'
          end
          expect(page).to have_current_path resource_iri(user).path
        end.to change { Doorkeeper::AccessToken.count }.by(1)
      end
    end

    describe 'with oauth' do
      setup { omniauth_user }

      scenario 'directly' do
        visit(new_user_session_path)
        expect do
          click_link 'Log in with Facebook'
          expect(page).to have_current_path(resource_iri(holland).path)
        end.to change { Doorkeeper::AccessToken.count }.by(1)
      end
    end
  end

  describe 'logout' do
    scenario 'with credentials' do
      visit(resource_iri(holland))
      sign_in_manually(user, false, redirect_to: resource_iri(holland).path)
      t = Doorkeeper::AccessToken.last

      expect(page).to have_selector('.dropdown-trigger.navbar-profile')
      expect(page).to have_current_path resource_iri(holland).path
      expect(t.expired?).to be_falsey

      within('.navbar-profile-selector') do
        page.find('.dropdown-trigger.navbar-profile', visible: true).click
        click_link 'Sign out'
      end
      expect(page).to have_content 'You have signed out successfully'
      expect(page).to have_current_path resource_iri(holland).path
      expect(Doorkeeper::AccessToken.find_by(id: t.id)).to be_falsey
    end

    describe 'with oauth' do
      setup { omniauth_user }

      scenario 'directly' do
        visit(new_user_session_path)
        click_link 'Log in with Facebook'
        expect(page).to have_current_path(resource_iri(holland).path)
        t = Doorkeeper::AccessToken.last

        visit(destroy_user_session_path)
        expect(Doorkeeper::AccessToken.find_by(id: t.id)).to be_falsey
      end
    end
  end
end
