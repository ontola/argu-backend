# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Decisions', type: :feature do
  define_freetown
  let(:forwarded_to) { create(:group, parent: freetown.page.edge) }
  let!(:motion) { create(:motion, parent: freetown.edge) }

  ####################################
  # As super admin
  ####################################
  let(:super_admin) { create_super_admin(freetown) }

  scenario 'super_admin should approve' do
    skip if ENV['BROWSER'] == 'chrome'
    sign_in(super_admin)

    visit motion_decisions_path(motion)
    click_link 'Approve'
    expect(page).to have_content('Explain this decision')
    expect do
      within('form.decision') do
        fill_in 'decision_content', with: 'Reason to take decision'
        click_button 'Save'
      end
      expect(page).to have_content('Idea is approved')
    end.to change { Decision.count }.by(1)
    expect(page).to have_content('Reason to take decision')
  end

  scenario 'super_admin should forward' do
    skip if ENV['BROWSER'] == 'chrome'
    forwarded_to
    sign_in(super_admin)

    visit motion_decisions_path(motion)
    click_link 'Forward'
    expect(page).to have_content('Group or user')
    expect do
      within('form.decision') do
        fill_in 'decision_content', with: 'Reason to forward decision'
        within('section .forward') do
          fill_in_select with: forwarded_to.display_name
        end
        click_button 'Save'
      end
      expect(page).to have_content('Decision is forwarded')
    end.to change { Decision.count }.by(1)
    expect(page).to have_content('Reason to forward decision')
  end

  scenario 'super_admin should reject' do
    skip if ENV['BROWSER'] == 'chrome'
    sign_in(super_admin)

    visit motion_decisions_path(motion)
    click_link 'Reject'
    expect(page).to have_content('Explain this decision')
    expect do
      within('form.decision') do
        fill_in 'decision_content', with: 'Reason to take decision'
        click_button 'Save'
      end
      expect(page).to have_content('Idea is rejected')
    end.to change { Decision.count }.by(1)
    expect(page).to have_content('Reason to take decision')
  end
end
