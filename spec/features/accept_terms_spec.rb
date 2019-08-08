# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Accept terms spec', type: :feature do
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }
  let(:user) { create(:user, :not_accepted_terms) }
  let(:user_without_password) { create(:user, :not_accepted_terms, :no_password) }

  ####################################
  # As User without accepted terms
  ####################################
  scenario 'User without password should accept terms before posting motion' do
    create_email_mock('set_password', user_without_password.email, token_url: /.+/)
    accept_terms_before_posting_motion(user_without_password)
    assert_email_sent
  end

  scenario 'User should accept terms before posting motion' do
    accept_terms_before_posting_motion(user)
  end

  scenario 'User without password should accept terms before voting' do
    create_email_mock('set_password', user_without_password.email, token_url: /.+/)
    accept_terms_before_voting(user_without_password)
    assert_email_sent
  end

  scenario 'User should accept terms before voting' do
    accept_terms_before_voting(user)
  end

  private

  def accept_terms_before_posting_motion(user) # rubocop:disable Metrics/AbcSize
    motion_attr = attributes_for(:motion)
    sign_in user

    visit new_iri(freetown, :motions)

    within('#new_motion') do
      fill_in 'motion[display_name]', with: motion_attr[:title]
      fill_in 'motion[description]', with: motion_attr[:content]
      click_button 'Save'
    end

    expect(page).to have_content('Terms of use')
    click_button 'Accept'

    expect(page).to have_content(motion_attr[:title].capitalize)
    expect(page).to have_current_path("#{Motion.last.iri.path}?start_motion_tour=true")
    expect(user.reload.accepted_terms?).to be_truthy
  end

  def accept_terms_before_voting(user) # rubocop:disable Metrics/AbcSize
    sign_in user

    visit motion
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-con[data-voted-on=true]')
    find('span', text: 'Disagree').click

    expect(page).to have_content('Terms of use')
    click_button 'Accept'

    expect(page).to have_css('.btn-con[data-voted-on=true]')

    expect(user.reload.accepted_terms?).to be_truthy
  end
end
