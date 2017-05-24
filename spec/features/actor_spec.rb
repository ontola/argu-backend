# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Page deletion', type: :feature do
  define_freetown
  let(:user) { create(:user) }
  let!(:forum_page) { create(:page, owner: user.profile) }
  navbar_query = '//a[@class="dropdown-trigger navbar-item navbar-profile"]'

  describe '#put' do
    scenario 'user switches profile to page' do
      sign_in(user)

      visit root_path
      page.find('.navbar-profile-selector').click
      accept_alert do
        click_on forum_page.display_name
      end
      expect(page.find(:xpath, navbar_query)[:href])
          .to eq(page_url(forum_page, host: Rails.application.config.host_name))
    end
  end
end
