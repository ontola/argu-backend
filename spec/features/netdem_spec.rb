require 'rails_helper'

RSpec.feature 'Netdem', type: :feature do

  let!(:freetown) { create(:forum, name: 'freetown') }
  let!(:netdem) { create(:group, name: 'Netwerk Democratie', forum: freetown) }
  let!(:netdem_member) { create_member(freetown) }
  let!(:netdem_membership) do
    create(:group_membership,
           member: netdem_member.profile,
           group: netdem)
  end
  let!(:netdem_rule_new) do
    create(:rule,
           context: freetown,
           model_type: 'Project',
           action: 'new?',
           role: netdem.identifier,
           permit: true)
  end
  let!(:netdem_rule_create) do
    create(:rule,
           context: freetown,
           model_type: 'Project',
           action: 'create?',
           role: netdem.identifier,
           permit: true)
  end

  scenario 'Netdem creates a project' do
    visit(forum_path('freetown'))

    click_link('sign_in')
    within('#new_user') do
      fill_in 'user_email', with: netdem_member.email
      fill_in 'user_password', with: 'password'
      click_button 'log_in'
    end

    expect(page).to have_content 'Welcome back!'
    expect(current_path).to eq forum_path('freetown')

    click_link('New discussion')

    click_link('new project')

    project_attributes = attributes_for(:project)
    within('#new_project') do
      fill_in 'project_title', with: project_attributes[:title]
      fill_in 'project_content', with: project_attributes[:content]
      click_link 'Add manager'
      all("input[name*='project[stepups_attributes]']")
        .find("input[name*='[moderator]']")
        .first
        .set(netdem.name)
      click_button 'Save'
    end
    expect(page).to have_content project_attributes[:title]
    expect(current_path).to eq project_path(Project.last)
  end
end
