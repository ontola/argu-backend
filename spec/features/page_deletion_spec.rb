require 'rails_helper'

RSpec.feature 'Page deletion', type: :feature do
  define_freetown
  let(:user) { create(:user) }
  let(:motion) do
    create(:motion,
           creator: forum_page.profile,
           parent: freetown.edge,
           publisher: user)
  end
  let(:question) do
    create(:question,
           creator: forum_page.profile,
           parent: freetown.edge,
           publisher: user)
  end
  let(:argument) do
    create(:argument,
           creator: forum_page.profile,
           parent: motion.edge,
           publisher: user)
  end
  let(:group_response) do
    create(:group_response,
           creator: forum_page.profile,
           parent: motion.edge,
           group: create(:group, parent: freetown.edge),
           publisher: user)
  end
  let(:project) do
    create(:project,
           creator: forum_page.profile,
           parent: freetown.edge,
           publisher: user)
  end
  let(:blog_post) do
    create(:blog_post,
           creator: forum_page.profile,
           parent: project.edge,
           publisher: user)
  end
  let(:comment) do
    create(:comment,
           parent: argument.edge,
           creator: forum_page.profile,
           publisher: user)
  end
  let!(:forum_page) { create(:page, owner: user.profile) }

  scenario 'user should delete destroy' do
    [argument, motion, question, group_response, project, blog_post, comment].each do |resource|
      resource.update(created_at: 1.day.ago)
    end

    login_as(user, scope: :user)
    visit pages_user_path(user)
    click_link 'Settings'
    click_link 'Advanced'
    click_link 'f_delete'
    expect do
      within(".confirm.page#edit_page_#{forum_page.id}") do
        fill_in 'page_repeat_name', with: forum_page.shortname.shortname
        click_button 'I understand the consequences, delete this page'
      end
    end.to change { Page.count }.by(-1)

    expect(page).to have_content 'Organization deleted successfully'
    [Comment, Argument, Motion, Question, Project, BlogPost].each do |klass|
      expect(klass.anonymous.count).to eq(1)
    end
    expect(GroupResponse.count).to eq(0)
  end

  scenario 'owner should not delete destroy' do
    argument.update(created_at: 1.day.ago)
    motion.update(created_at: 1.day.ago)
    comment
    freetown.update(page_id: forum_page.id)

    login_as(user, scope: :user)
    visit pages_user_path(user)
    click_link 'Settings'
    click_link 'Advanced'
    click_link 'f_delete'

    expect(page).to have_content 'This page owns one or multiple forums. '\
                                 'Transfer these forum to another page or contact Argu before proceeding.'
  end
end
