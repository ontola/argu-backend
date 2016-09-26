# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Decisions', type: :feature do
  define_freetown
  let(:forwarded_to) { create(:group, parent: freetown.page.edge) }
  let!(:motion) { create(:motion, parent: freetown.edge) }

  ####################################
  # As manager
  ####################################
  let(:manager) { create_manager(freetown) }

  scenario 'manager should approve' do
    skip if ENV['BROWSER'] == 'chrome'
    sign_in(manager)

    visit motion_path(motion)
    click_link 'Take decision'
    click_link 'Pass'
    expect(page).to have_content('Explain this decision')
    expect do
      within('form.decision') do
        fill_in 'decision_content', with: 'Reason to take decision'
        click_button 'Save'
      end
    end.to change { Decision.count }.by(1)
    expect(page).to have_content('Motion is passed')
    expect(page).to have_content('Reason to take decision')
  end

  scenario 'manager should forward' do
    skip if ENV['BROWSER'] == 'chrome'
    forwarded_to
    sign_in(manager)

    visit motion_path(motion)
    click_link 'Take decision'
    click_link 'Forward'
    expect(page).to have_content('Group or user')
    expect do
      within('form.decision') do
        fill_in 'decision_content', with: 'Reason to forward decision'
        fill_in_select with: forwarded_to.display_name
        click_button 'Save'
      end
    end.to change { Decision.count }.by(1)
    expect(page).to have_content('Motion is forwarded')
    expect(page).to have_content('Reason to forward decision')
  end

  scenario 'manager should reject' do
    skip if ENV['BROWSER'] == 'chrome'
    sign_in(manager)

    visit motion_path(motion)
    click_link 'Take decision'
    click_link 'Reject'
    expect(page).to have_content('Explain this decision')
    expect do
      within('form.decision') do
        fill_in 'decision_content', with: 'Reason to take decision'
        click_button 'Save'
      end
    end.to change { Decision.count }.by(1)
    expect(page).to have_content('Motion is rejected')
    expect(page).to have_content('Reason to take decision')
  end
end
