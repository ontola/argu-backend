require 'rails_helper'

RSpec.feature 'Voting', type: :feature do
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  scenario 'Member should place comment without body' do
    sign_in member

    visit motion_path(motion)
    within('[page_param="page_arg_pro"]') do
      click_link 'Add argument'
    end

    argument_attributes = attributes_for(:argument)

    within('#new_argument') do
      fill_in 'argument_title', with: argument_attributes[:title]
      click_button 'Save'
    end

    expect(page).to have_current_path(motion_path(motion))
    expect(page).to have_css('.btn-con')
    expect(page).not_to have_content argument_attributes[:title]
  end
end
