# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Shortname', type: :feature do
  define_freetown(attributes: {name: 'freetown', max_shortname_count: 3})
  let(:staff) { create(:user, :staff) }
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:upcase_page) do
    create(:page,
           shortname: build(:shortname,
                            shortname: 'PAGE'))
  end

  scenario 'should resolve uppercase shortnames' do
    visit forum_path(upcase_page.url.downcase)
    expect(page).to have_current_path page_path(upcase_page.url)
    expect(page).to have_content(upcase_page.display_name)
  end

  scenario 'staff creates a shortname' do
    sign_in staff
    general_create
  end

  scenario 'staff destroys a shortname' do
    create(:discussion_shortname, forum: freetown, owner: create(:motion, parent: freetown.edge))
    sign_in staff
    general_destroy
  end

  private

  def general_create(_response = 200)
    motion
    visit shortname_settings_path
    expect(page).to have_content('0 out of 3')

    click_link 'New Argu URL'
    expect(page).to have_current_path new_forum_shortname_path(freetown)

    shortname_attrs = attributes_for(:shortname)

    expect do
      within('#new_shortname') do
        fill_in 'shortname_shortname', with: shortname_attrs[:shortname]
        select('Motion', from: 'shortname_owner_type')
        fill_in 'shortname_owner_id', with: motion.id
        click_on 'Save'
      end
      expect(page).to have_current_path shortname_settings_path
    end.to change { Shortname.count }.by(1)
  end

  def general_destroy(_response = 200)
    s = freetown.shortnames.first
    expect do
      visit shortname_settings_path
      page.accept_alert do
        click_link 'Delete'
      end
      expect(page).not_to have_content(s.shortname)
    end.to change { freetown.shortnames.count }.by(-1)
  end

  def shortname_settings_path
    settings_forum_path(freetown, tab: 'shortnames')
  end
end
