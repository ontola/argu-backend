# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Account deletion', type: :feature do
  define_freetown
  let(:user) { create(:user) }
  let(:motion) do
    create(:motion,
           creator: user.profile,
           publisher: user,
           parent: freetown)
  end
  let(:question) do
    create(:question,
           creator: user.profile,
           publisher: user,
           parent: freetown)
  end
  let(:argument) do
    create(:argument,
           creator: user.profile,
           parent: motion,
           publisher: user)
  end
  let(:blog_post) do
    create(:blog_post,
           creator: user.profile,
           parent: question,
           publisher: user)
  end
  let(:comment) do
    create(:comment,
           parent: argument,
           creator: user.profile,
           publisher: user)
  end

  scenario 'user should delete destroy' do
    [argument, motion, question, blog_post, comment].each do |resource|
      resource.update(created_at: 1.day.ago)
    end

    sign_in_manually(user)
    ActsAsTenant.with_tenant(argu) do
      RequestStore.store[:old_frontend] = true
      visit settings_iri('/u', tab: :advanced)
    end
    click_link 'Delete Argu account'
    expect do
      within("#edit_user_#{user.id}") do
        fill_in 'user_confirmation_string', with: 'remove'
        click_button 'I understand the consequences, delete my account'
      end
      expect(page).to have_content 'Account deleted successfully'
    end.to change { User.count }.by(-1)
    argument.reload

    [Comment, Argument, Motion, Question, BlogPost].each do |klass|
      expect(klass.anonymous.count).to eq(1)
    end
    visit motion
    expect(page).to have_content 'community'
  end

  scenario 'administrator should not delete destroy' do
    sign_in(create_administrator(freetown))
    ActsAsTenant.with_tenant(argu) do
      RequestStore.store[:old_frontend] = true
      visit settings_iri('/u', tab: :advanced)
    end
    click_link 'Delete Argu account'

    expect(page).to have_content 'You are the administrator in one or more places. '\
                                 'If you want to delete your account, please first transfer or remove these rights'
  end
end
