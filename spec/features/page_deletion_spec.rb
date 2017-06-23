# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Page deletion', type: :feature do
  let!(:default_forum) { create(:setting, key: 'default_forum', value: 'freetown') }
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
           publisher: user,
           happening_attributes: {happened_at: DateTime.current})
  end
  let(:comment) do
    create(:comment,
           parent: argument.edge,
           creator: forum_page.profile,
           publisher: user)
  end
  let!(:forum_page) { create(:page, owner: user.profile) }

  scenario 'user should delete destroy' do
    [argument, motion, question, project, blog_post, comment].each do |resource|
      resource.update(created_at: 1.day.ago)
    end

    sign_in(user)
    visit pages_user_path(user)
    click_link 'Settings'
    click_link 'Advanced'
    click_link 'Delete'
    expect do
      within(".confirm.page#edit_page_#{forum_page.id}") do
        fill_in 'page_confirmation_string', with: 'remove'
        click_button 'I understand the consequences, delete this page'
      end
      expect(page).to have_content 'Organization deleted successfully'
    end.to change { Page.count }.by(-1)

    [Comment, Argument, Motion, Question, Project, BlogPost].each do |klass|
      expect(klass.anonymous.count).to eq(1)
    end
  end

  scenario 'owner should not delete destroy' do
    [argument, motion, question, project, blog_post, comment].each do |resource|
      resource.update(created_at: 1.day.ago)
    end
    freetown.update(page_id: forum_page.id)

    sign_in(user)
    visit pages_user_path(user)
    click_link 'Settings'
    click_link 'Advanced'
    click_link 'Delete'

    expect(page).to have_content 'This page owns one or multiple forums. '\
                                 'Transfer these forum to another page or contact Argu before proceeding.'
  end
end
