require 'rails_helper'

RSpec.feature 'Account deletion', type: :feature do
  define_freetown
  let(:user) { create(:user) }
  let(:motion) do
    create(:motion,
           creator: user.profile,
           publisher: user,
           parent: freetown.edge)
  end
  let(:question) do
    create(:question,
           creator: user.profile,
           publisher: user,
           parent: freetown.edge)
  end
  let(:argument) do
    create(:argument,
           creator: user.profile,
           parent: motion.edge,
           publisher: user)
  end
  let(:group_response) do
    create(:group_response,
           group: create(:group, parent: freetown.page.edge),
           creator: user.profile,
           parent: motion.edge,
           publisher: user)
  end
  let(:project) do
    create(:project,
           creator: user.profile,
           parent: freetown.edge,
           publisher: user)
  end
  let(:blog_post) do
    create(:blog_post,
           creator: user.profile,
           parent: project.edge,
           publisher: user)
  end
  let(:comment) do
    create(:comment,
           parent: argument.edge,
           creator: user.profile,
           publisher: user)
  end
  let(:forum_page) do
    create(:page,
           owner: user.profile)
  end

  scenario 'user should delete destroy' do
    [argument, motion, question, group_response, project, blog_post, comment].each do |resource|
      resource.update(created_at: 1.day.ago)
    end

    sign_in(user)
    visit settings_path(tab: :advanced)
    click_link 'Delete Argu account'
    expect do
      within("#edit_user_#{user.id}") do
        fill_in 'user_repeat_name', with: user.shortname.shortname
        fill_in 'user_current_password', with: user.password
        click_button 'I understand the consequences, delete my account'
      end
    end.to change { User.count }.by(-1)
    argument.reload

    expect(page).to have_content 'Account deleted successfully'
    [Comment, Argument, Motion, Question, Project, BlogPost].each do |klass|
      expect(klass.anonymous.count).to eq(1)
    end
    expect(GroupResponse.count).to eq(0)
    visit motion_path(motion)
    expect(page).to have_content 'community'
  end

  scenario 'owner should not delete destroy' do
    forum_page

    login_as(user, scope: :user)
    visit settings_path(tab: :advanced)
    click_link 'Delete Argu account'

    expect(page).to have_content 'You are the owner of one or multiple pages. '\
                                 'If you want to delete your account, please transfer or delete these pages first'
  end

end
