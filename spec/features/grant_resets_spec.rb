# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Grant resets', type: :feature do
  define_spain
  let(:question) { create(:question, parent: spain.edge) }
  let(:staff) { create(:user, :staff) }

  scenario 'set and revert grant reset' do
    sign_in staff
    visit edit_iri_path(question)
    expect(find_field('question[reset_create_motion]', with: 'false')).to be_checked
    expect(find_field('question[reset_create_motion]', with: 'true')).not_to be_checked

    find_field('question[reset_create_motion]', with: 'true').click

    expect(find_field('question[create_motion_group_ids][]', with: Group::PUBLIC_ID)).not_to be_checked
    expect(find_field('question[create_motion_group_ids][]', with: Group::STAFF_ID)).to be_checked
    expect(find_field('question[create_motion_group_ids][]', with: spain.page.groups.first.id)).to be_checked

    find_field('question[create_motion_group_ids][]', with: '-1').click
    find_field('question[create_motion_group_ids][]', with: spain.page.groups.first.id).click

    assert_differences([['GrantReset.count', 1], ['Grant.count', 2]]) do
      click_button 'Save'
      expect(page).to have_content 'Challenge saved successfully'
    end

    visit edit_iri_path(question)
    expect(page).to have_current_path edit_iri_path(question)
    expect(find_field('question[reset_create_motion]', with: 'false')).not_to be_checked
    expect(find_field('question[reset_create_motion]', with: 'true')).to be_checked

    expect(find_field('question[create_motion_group_ids][]', with: Group::PUBLIC_ID)).to be_checked
    expect(find_field('question[create_motion_group_ids][]', with: Group::STAFF_ID)).to be_checked
    expect(find_field('question[create_motion_group_ids][]', with: spain.page.groups.first.id)).not_to be_checked

    find_field('question[reset_create_motion]', with: 'false').click

    assert_differences([['GrantReset.count', -1], ['Grant.count', -2]]) do
      click_button 'Save'
      expect(page).to have_content 'Challenge saved successfully'
    end
  end
end
