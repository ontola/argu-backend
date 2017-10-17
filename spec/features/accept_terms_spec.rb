# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Accept terms spec', type: :feature do
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:user) { create(:user, :not_accepted_terms) }

  ####################################
  # As User without accepted terms
  ####################################
  scenario 'User should accept terms before posting motion' do
    motion_attr = attributes_for(:motion)

    sign_in user

    visit new_forum_motion_path(freetown)

    within('#new_motion') do
      fill_in 'motion[title]', with: motion_attr[:title]
      fill_in 'motion[content]', with: motion_attr[:content]
      click_button 'Save'
    end

    expect(page).to have_content('Terms of use')
    click_button 'Accept'

    expect(page).to have_content(motion_attr[:title].capitalize)
    expect(page).to have_current_path(motion_path(Motion.last, start_motion_tour: true))
  end

  scenario 'User should accept terms before voting' do
    sign_in user
    visit motion_path(motion)
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('span', text: 'I\'m against').click

    expect(page).to have_content('Terms of use')
    click_button 'Accept'

    expect(page).to have_css('.btn-con[data-voted-on=true]')

    find_field('opinion-body').click
    within('.opinion-form') do
      fill_in 'opinion-body', with: 'This is my opinion'
      click_button 'Save'
    end
    expect(page).not_to have_content('Would you like to comment on your opinion?')

    visit motion_path(motion)
    expect(page).to have_content('Opinions')
    within('.opinion-columns') do
      expect(page).to have_content('This is my opinion')
    end
  end
end
