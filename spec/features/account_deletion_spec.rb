require 'rails_helper'

RSpec.feature 'Account deletion', type: :feature do
  let(:freetown) { create(:forum, name: 'freetown') }
  let(:user) { create(:user) }
  let(:motion) { create(:motion,
                        creator: user.profile,
                        publisher: user) }
  let(:argument) { create(:argument,
                          creator: user.profile,
                          motion: motion,
                          publisher: user) }
  let(:comment) { create(:comment,
                         commentable: argument,
                         creator: user.profile,
                         publisher: user) }

  scenario 'user should delete destroy' do
    argument.update(created_at: 1.day.ago)
    motion.update(created_at: 1.day.ago)
    comment

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
    expect(Comment.anonymous.count).to eq(1)
    expect(Argument.anonymous.count).to eq(1)
    expect(Motion.anonymous.count).to eq(1)
  end

end
