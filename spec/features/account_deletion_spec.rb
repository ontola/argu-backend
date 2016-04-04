require 'rails_helper'

RSpec.feature 'Account deletion', type: :feature do
  let(:freetown) { create(:forum, name: 'freetown') }
  let(:user) { create(:user) }
  let(:motion) { create(:motion,
                        creator: user.profile,
                        publisher: user) }
  let(:question) { create(:question,
                          creator: user.profile,
                          publisher: user) }
  let(:argument) { create(:argument,
                          creator: user.profile,
                          motion: motion,
                          publisher: user) }
  let(:group_response) { create(:group_response,
                                creator: user.profile,
                                motion: motion,
                                publisher: user) }
  let(:project) { create(:project,
                         creator: user.profile,
                         publisher: user) }
  let(:blog_post) { create(:blog_post,
                           creator: user.profile,
                           blog_postable: project,
                           publisher: user) }
  let(:comment) { create(:comment,
                         commentable: argument,
                         creator: user.profile,
                         publisher: user) }
  let (:forum_page) { create(:page,
                             owner: user.profile)}

  scenario 'user should delete destroy' do
    [argument, motion, question, group_response, project, blog_post, comment].each do |resource|
      resource.update(created_at: 1.day.ago)
    end

    login_as(user, scope: :user)
    visit settings_path
    click_link 'Delete Argu account'
    expect {
      within("#edit_user_#{user.id}") do
        fill_in 'user_repeat_name', with: user.shortname.shortname
        click_button 'I understand the consequences, delete my account'
      end
    }.to change { User.count }.by(-1)
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
    visit settings_path
    click_link 'Delete Argu account'

    expect(page).to have_content 'You are the owner of one or multiple pages. If you want to delete your account, please transfer or delete these pages first'
  end

end
