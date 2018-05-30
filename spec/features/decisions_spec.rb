# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Decisions', type: :feature do
  define_freetown
  let(:forwarded_to) { create(:group, parent: argu) }
  let!(:motion) { create(:motion, parent: freetown) }

  ####################################
  # As administrator
  ####################################
  let(:administrator) { create_administrator(freetown) }

  scenario 'administrator should approve' do
    skip if ENV['BROWSER'] == 'chrome'
    sign_in(administrator)

    visit collection_iri_path(motion, :decisions)
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

  scenario 'administrator should forward' do
    skip if ENV['BROWSER'] == 'chrome'
    forwarded_to
    sign_in(administrator)

    visit collection_iri_path(motion, :decisions)
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

  scenario 'administrator should reject' do
    skip if ENV['BROWSER'] == 'chrome'
    sign_in(administrator)

    visit collection_iri_path(motion, :decisions)
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
