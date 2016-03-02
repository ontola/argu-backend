require 'rails_helper'

RSpec.feature 'Login', type: :feature do

  let(:freetown) { create(:forum, name: 'freetown') }
  let(:motion) do
    create(:motion,
           forum: freetown)
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  scenario 'User should vote on a motion' do
    login_as(user)

    visit motion_path(motion)
    expect(page).to have_content(motion.content)

    find('span span', text: 'IK BEN VOOR').click
    expect(page).to have_content('Bedankt voor je stem!')

    visit motion_path(motion)
    expect(page).to have_css('.btn-pro[data-voted-on=true]')
  end

end
