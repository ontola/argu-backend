# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Shortname', type: :feature do
  define_freetown(attributes: {name: 'freetown'})
  let(:administrator) { create_administrator(argu) }
  let(:motion) { create(:motion, parent: freetown) }
  let!(:shortname) { create(:discussion_shortname, owner: create(:motion, parent: freetown), primary: false) }

  scenario 'administrator creates a shortname' do
    sign_in administrator
    general_create
  end

  scenario 'administrator destroys a shortname' do
    sign_in administrator
    general_destroy
  end

  private

  def general_create(_response = 200) # rubocop:disable Metrics/AbcSize
    motion
    visit settings_iri(argu, tab: 'shortnames')

    click_link 'New Redirect'
    expect(page).to have_current_path new_iri(argu, :shortnames)

    shortname_attrs = attributes_for(:shortname)

    expect do
      within('#new_shortname') do
        fill_in 'shortname_shortname', with: shortname_attrs[:shortname]
        fill_in 'shortname_destination', with: "m/#{motion.fragment}"
        click_on 'Save'
      end
      expect(page).to have_current_path "#{settings_iri(argu).path}?tab=shortnames"
    end.to change { Shortname.count }.by(1)
  end

  def general_destroy(_response = 200) # rubocop:disable Metrics/AbcSize
    expect do
      visit settings_iri(argu, tab: 'shortnames')
      page.accept_alert do
        click_link 'Delete'
      end
      expect(page).not_to have_content(shortname.shortname)
    end.to change { Shortname.count }.by(-1)
  end
end
