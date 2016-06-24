require 'rails_helper'

RSpec.feature 'Show drafts', type: :feature do
  let!(:freetown) { create(:forum) }
  let(:user) { create(:user, has_drafts: true) }
  let(:user2) { create(:user, has_drafts: true) }
  let!(:blog_post) do
    create(:blog_post, blog_postable: project, happened_at: DateTime.current, forum: freetown, publisher: user)
  end
  let!(:published_blog_post) do
    create(:blog_post,
           blog_postable: project,
           happened_at: DateTime.current,
           forum: freetown,
           argu_publication: build(:publication),
           publisher: user)
  end
  let!(:project) do
    create(:project, forum: freetown, publisher: user)
  end
  let!(:published_project) do
    create(:project, forum: freetown, argu_publication: build(:publication), publisher: user)
  end

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
