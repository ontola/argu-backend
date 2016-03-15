require 'rails_helper'

RSpec.feature 'Adam west', type: :feature do
  let!(:default) { create(:forum) }
  let!(:freetown) do
    create(:forum,
           name: 'freetown')
  end
  let!(:f_rule_f_s) do
    create(:rule,
           model_type: 'Forum',
           model_id: freetown.id,
           action: 'show?',
           role: 'member',
           permit: false,
           context_type: 'Forum',
           context_id: freetown.id)
  end
  let!(:f_rule_f_l) do
    create(:rule,
           model_type: 'Forum',
           model_id: freetown.id,
           action: 'list?',
           role: 'member',
           permit: false,
           context_type: 'Forum',
           context_id: freetown.id)
  end
  let!(:f_rule_c) do
    %w(index? show? create? new?).each do |action|
      create(:rule,
             model_type: 'Comment',
             model_id: nil,
             action: action,
             role: 'manager',
             permit: false,
             context_type: 'Forum',
             context_id: freetown.id)
    end
  end
  let!(:f_rule_q_c) do
    create(:rule,
           model_type: 'Question',
           model_id: nil,
           action: :create?,
           role: 'member',
           permit: false,
           context_type: 'Forum',
           context_id: freetown.id)
  end
  let!(:f_rule_q_n) do
    create(:rule,
           model_type: 'Question',
           model_id: nil,
           action: :new?,
           role: 'member',
           permit: false,
           context_type: 'Forum',
           context_id: freetown.id)
  end
  let!(:f_rule_m_nwq) do
    create(:rule,
           model_type: 'Motion',
           model_id: nil,
           action: :new_without_question?,
           role: 'member',
           permit: false,
           context_type: 'Forum',
           context_id: freetown.id)
  end
  let!(:f_rule_m_cwq) do
    create(:rule,
           model_type: 'Motion',
           model_id: nil,
           action: :create_without_question?,
           role: 'member',
           permit: false,
           context_type: 'Forum',
           context_id: freetown.id)
  end
  let!(:question) do
    create(:question,
           forum: freetown)
  end
  let!(:motion) do
    create(:motion,
           question: question,
           forum: freetown)
  end
  let!(:argument) do
    create(:argument,
           motion: motion,
           forum: freetown)
  end
  let(:comment) do
    create :comment,
           commentable: argument,
           forum: freetown
  end

  ####################################
  # As Guest
  ####################################

  scenario 'guest should walk from answer up until question' do
    visit argument_path(argument)
    expect(page).to have_content(argument.title)
    expect(page).to have_content(argument.content)

    click_link motion.title
    expect(current_path).to eq motion_path(motion)
    expect(page).to have_content(motion.title)
    expect(page).to have_content(motion.content)

    click_link question.title
    expect(current_path).to eq question_path(question)
    expect(page).to have_content(question.title)
    expect(page).to have_content(question.content)

    expect(page).not_to have_content(freetown.display_name)
  end

  scenario 'guest should not visit forum show' do
    visit forum_path(freetown)

    expect(page).not_to have_content(freetown.display_name)
    expect(current_path).to eq(forum_path(default))
  end

  scenario 'guest should not see comment section' do
    visit argument_path(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  scenario 'user should walk from answer up until question' do
    login_as(user, scope: :user)

    visit argument_path(argument)
    expect(page).to have_css("img[src*='#{user.profile.profile_photo.url(:icon)}']")
    expect(page).to have_content(argument.title)
    expect(page).to have_content(argument.content)

    click_link motion.title
    expect(current_path).to eq motion_path(motion)
    expect(page).to have_content(motion.title)
    expect(page).to have_content(motion.content)

    click_link question.title
    expect(current_path).to eq question_path(question)
    expect(page).to have_content(question.title)
    expect(page).to have_content(question.content)

    expect(page).not_to have_content(freetown.display_name)
  end

  scenario 'user should not visit forum show' do
    login_as(user, scope: :user)

    visit forum_path(freetown)

    expect(page).not_to have_content(freetown.display_name)
    expect(current_path).to eq(forum_path(default))
  end

  scenario 'user should not see comment section' do
    login_as(user, scope: :user)

    visit argument_path(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  scenario 'member should walk from answer up until question' do
    login_as(member, scope: :user)

    visit argument_path(argument)
    expect(page).to have_css("img[src*='#{member.profile.profile_photo.url(:icon)}']")
    expect(page).to have_content(argument.title)
    expect(page).to have_content(argument.content)

    click_link motion.title
    expect(current_path).to eq motion_path(motion)
    expect(page).to have_content(motion.title)
    expect(page).to have_content(motion.content)
    expect(page.body).not_to have_content('Start a new discussion')

    click_link question.title
    expect(current_path).to eq question_path(question)
    expect(page).to have_content(question.title)
    expect(page).to have_content(question.content)

    expect(page).not_to have_content(freetown.display_name)
  end

  scenario 'member should not visit forum show' do
    login_as(member, scope: :user)

    visit forum_path(freetown)

    expect(page).not_to have_content(freetown.display_name)
    expect(current_path).to eq(forum_path(default))
  end

  scenario 'member should not see comment section' do
    login_as(member, scope: :user)

    visit argument_path(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end

  scenario 'member should not see top comment' do
    login_as(member, scope: :user)

    visit motion_path(motion)

    expect(page).to have_content(argument.title)
    expect(page).not_to have_content(comment.body)
    expect(page.body).not_to have_content('Reply')

    # Anti-test
    arg = create(:argument)

    visit motion_path(arg.motion)

    expect(page).to have_content(arg.title)
    expect(page.body).to have_content('Reply')
    expect(page.body).to have_content('Start a new discussion')

    c = create(:comment,
               commentable: arg)

    visit motion_path(arg.motion)
    expect(page).to have_content(arg.title)
    expect(page).to have_content(c.body)
  end

  scenario 'member should not post create comment' do
    login_as(member, scope: :user)

    visit argument_path(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end


  scenario 'guest should not see comment section' do
    visit argument_path(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager(freetown) }

  scenario 'manager should walk from answer up until forum' do
    login_as(manager, scope: :user)

    visit argument_path(argument)
    expect(page).to have_css("img[src*='#{manager.profile.profile_photo.url(:icon)}']")
    expect(page).to have_content(argument.title)
    expect(page).to have_content(argument.content)

    click_link motion.title
    expect(current_path).to eq motion_path(motion)
    expect(page).to have_content(motion.title)
    expect(page).to have_content(motion.content)

    click_link question.title
    expect(current_path).to eq question_path(question)
    expect(page).to have_content(question.title)
    expect(page).to have_content(question.content)

    click_link freetown.display_name
    expect(current_path).to eq forum_path(freetown)
    expect(page).to have_content(freetown.display_name)
    expect(page).to have_content(freetown.bio)
    expect(page.body).to have_content('Forum settings')
  end

  scenario 'manager should visit forum show' do
    login_as(manager, scope: :user)

    visit forum_path(freetown)

    expect(page).to have_content(freetown.display_name)
    expect(page).to have_content(freetown.bio)
    expect(current_path).to eq(forum_path(freetown))
  end

  scenario 'manager should not see comment section' do
    login_as(manager, scope: :user)

    visit argument_path(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end
end
