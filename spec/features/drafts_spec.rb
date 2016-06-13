require 'rails_helper'

RSpec.feature 'Show drafts', type: :feature do
  let!(:freetown) { create(:forum) }
  let(:user) { create(:user, has_drafts: true) }
  let(:user2) { create(:user, has_drafts: true) }
  let!(:blog_post) { create(:blog_post, :unpublished, publisher: user) }
  let!(:published_blog_post) { create(:blog_post, :published, publisher: user) }
  let!(:project) { create(:project, :unpublished, publisher: user) }
  let!(:published_project) { create(:project, :published, publisher: user) }

  scenario 'User with drafts shows drafts' do
    login_as(user, scope: :user)

    visit(drafts_user_path(user))

    expect(page).to have_selector('div.box.blog_post', text: blog_post.title, count: 1)
    expect(page).to have_selector('div.box.project', text: project.title, count: 1)
  end

  scenario 'User without drafts shows no drafts' do
    login_as(user2, scope: :user)

    visit(drafts_user_path(user2))

    expect(page).to have_content 'You currently have no drafts'
  end
end
