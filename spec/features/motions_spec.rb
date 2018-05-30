# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Motions', type: :feature do
  define_freetown
  let(:question) { create(:question, parent: freetown) }
  let(:administrator) { create_administrator(freetown) }

  scenario 'user should post a new motion as organization' do
    sign_in(administrator)

    visit new_iri_path(question, :motions)

    motion_attr = attributes_for(:motion)

    assert_differences([['Motion.count', 1]]) do
      within('#new_motion') do
        fill_in 'motion[title]', with: motion_attr[:title]
        fill_in 'motion[content]', with: motion_attr[:content]
        within('.Select-profile') do
          fill_in_select with: argu.display_name
        end
        click_button 'Save'
      end
      expect(page).to have_content(motion_attr[:title].capitalize)
    end

    expect(Motion.last.creator).to eq(argu.profile)
  end
end
