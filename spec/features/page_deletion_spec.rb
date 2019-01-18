# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Page deletion', type: :feature do
  let!(:default_forum) { create(:setting, key: 'default_forum', value: freetown.uuid) }
  define_freetown
  let(:user) { create(:user) }
  let(:motion) do
    create(:motion,
           creator: forum_page.profile,
           parent: freetown,
           publisher: user)
  end
  let(:question) do
    create(:question,
           creator: forum_page.profile,
           parent: freetown,
           publisher: user)
  end
  let(:argument) do
    create(:argument,
           creator: forum_page.profile,
           parent: motion,
           publisher: user)
  end
  let(:blog_post) do
    create(:blog_post,
           creator: forum_page.profile,
           parent: question,
           publisher: user)
  end
  let(:comment) do
    create(:comment,
           parent: argument,
           creator: forum_page.profile,
           publisher: user)
  end
  let!(:forum_page) { create_page(publisher: user, creator: user.profile) }
  let(:nederland) { create(:place, address: {'country_code' => 'nl'}) }

  scenario 'user should delete destroy' do
    nederland
    [argument, motion, question, blog_post, comment].each do |resource|
      resource.update(created_at: 1.day.ago)
    end

    sign_in(user)
    visit settings_iri(forum_page)
    click_link 'Advanced'
    click_link 'Delete'
    expect do
      within(".confirm.page#edit_page_#{forum_page.id}") do
        fill_in 'page_confirmation_string', with: 'remove'
        click_button 'I understand the consequences, delete this page.'
      end
      expect(page).to have_content 'Organization deleted successfully'
    end.to change { Page.count }.by(-1)

    [Comment, Argument, Motion, Question, BlogPost].each do |klass|
      expect(klass.anonymous.count).to eq(1)
    end
  end

  scenario 'owner should not delete destroy' do
    nederland
    [argument, motion, question, blog_post, comment].each do |resource|
      resource.update(created_at: 1.day.ago)
    end
    freetown.move_to(forum_page)

    sign_in(user)
    visit settings_iri(argu)
    click_link 'Advanced'
    click_link 'Delete'

    expect(page).to have_content 'This page owns one or multiple forums. '\
                                 'Transfer these forum to another page or contact Argu before proceeding.'
  end
end
