# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Decisions', type: :feature do
  define_freetown
  let!(:motion) { create(:motion, parent: freetown.edge) }

  ####################################
  # As manager
  ####################################
  let(:manager) { create_manager(freetown) }

  scenario 'manager should approve' do
    sign_in(manager)

    visit motion_path(motion)
    click_link 'Take decision'
    click_link 'Pass'
    expect(page).to have_content('Explain this decision')
    within('form.decision') do
      fill_in 'decision_content', with: 'Reason to take decision'
      click_button 'Save'
    end
    expect(page).to have_content('Motion is passed')
    expect(page).to have_content('Reason to take decision')
  end

  scenario 'manager should reject' do
    sign_in(manager)

    visit motion_path(motion)
    click_link 'Take decision'
    click_link 'Reject'
    expect(page).to have_content('Explain this decision')
    within('form.decision') do
      fill_in 'decision_content', with: 'Reason to take decision'
      click_button 'Save'
    end
    expect(page).to have_content('Motion is rejected')
    expect(page).to have_content('Reason to take decision')
  end
end
