# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Show drafts', type: :feature do
  define_freetown
  let(:user) { create(:user, has_drafts: true) }
  let(:user2) { create(:user, has_drafts: true) }
  let!(:project) do
    create(:project,
           parent: freetown.edge,
           publisher: user,
           edge_attributes: {argu_publication_attributes: {publish_type: 'draft'}})
  end
  let!(:published_project) { create(:project, parent: freetown.edge, publisher: user) }
  let!(:blog_post) do
    create(:blog_post,
           parent: project.edge,
           happened_at: DateTime.current,
           publisher: user,
           edge_attributes: {argu_publication_attributes: {publish_type: 'draft'}})
  end
  let!(:published_blog_post) do
    create(:blog_post, parent: published_project.edge, happened_at: DateTime.current, publisher: user)
  end
  let!(:motion) do
    create(:motion,
           parent: freetown.edge,
           publisher: user,
           edge_attributes: {argu_publication_attributes: {publish_type: 'draft'}})
  end
  let!(:question) do
    create(:question,
           parent: freetown.edge,
           publisher: user,
           edge_attributes: {argu_publication_attributes: {publish_type: 'draft'}})
  end

  scenario 'User with drafts shows drafts' do
    sign_in(user)

    visit(drafts_user_path(user))

    expect(page).to have_selector('div.box.blog_post', text: blog_post.title, count: 1)
    expect(page).to have_selector('div.box.project', text: project.title, count: 1)
    expect(page).to have_selector('div.box.motion', text: motion.title, count: 1)
    expect(page).to have_selector('div.box.question', text: question.title, count: 1)
  end

  scenario 'User without drafts shows no drafts' do
    sign_in(user2)

    visit(drafts_user_path(user2))

    expect(page).to have_content 'You currently have no drafts'
  end
end
