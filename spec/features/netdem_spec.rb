require 'rails_helper'

RSpec.feature 'Netdem', type: :feature do
  define_freetown
  let!(:netdem) { create(:group, name: 'Netwerk Democratie', parent: freetown.page.edge) }
  let!(:netdem_member) { create_member(freetown) }
  let!(:netdem_membership) do
    create(:group_membership,
           member: netdem_member.profile,
           parent: netdem.edge)
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
    expect(page).to have_current_path forum_path('freetown')

    click_link('New discussion')

    click_link('New project')

    project_attributes = attributes_for(:project)
    within('#new_project') do
      fill_in 'project_title', with: project_attributes[:title]
      fill_in 'project_content', with: project_attributes[:content]
      click_link 'Add manager'
      all("input[name*='project[stepups_attributes]']")
        .find("input[name*='[moderator]']")
        .first
        .set(netdem.name)
      click_link 'Add phase'
      all("input[name*='project[phases_attributes]']")
          .find("input[name*='[name]']")
          .first
          .set('First phase')
      click_button 'Save'
    end
    expect(page).to have_content project_attributes[:title]
    expect(page).to have_content 'First phase'
    expect(page).to have_current_path project_path(Project.last)

    visit(edit_project_path(Project.last))
    within("#edit_project_#{Project.last.id}") do
      click_link 'Add phase'
      all("input[name*='project[phases_attributes]']")
          .find("input[name*='[name]']")
          .first
          .set('Second phase')
      click_button 'Save'
    end
    expect(page).to have_selector('.timeline-phase-title.current', text: 'First phase')

    click_link 'First phase'

    page.accept_confirm 'Finishing this phase will automatically start the next phase' do
      within('form.phase') do
        click_button 'Finish'
      end
    end
    expect(page).to have_content 'Phase saved successfully'
    expect(page).to have_selector('.timeline-phase-title.current', text: 'Second phase')
  end
end
