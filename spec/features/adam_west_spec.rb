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
    expect(page).to have_current_path motion_path(motion)
    expect(page).to have_content(motion.title)
    expect(page).to have_content(motion.content)

    click_link question.title
    expect(page).to have_current_path question_path(question)
    expect(page).to have_content(question.title)
    expect(page).to have_content(question.content)

    expect(page).not_to have_content(freetown.display_name)
  end

  scenario 'guest should not visit forum show' do
    visit forum_path(freetown)

    expect(page).not_to have_content(freetown.display_name)
    expect(page).to have_current_path(forum_path(default))
  end

  scenario 'guest should not see comment section' do
    visit argument_path(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end

  scenario 'guest should vote on a motion' do
    nominatim_netherlands

    visit motion_path(motion)
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-neutral[data-voted-on=true]')
    click_link 'Neutral'

    expect(page).to have_content 'Sign up'

    click_link 'Sign up with email'
    redirect_url = new_motion_vote_path(motion_id: motion,
                                        confirm: 'true',
                                        vote: {for: 'neutral'})
    expect(page).to have_current_path new_user_registration_path(r: redirect_url)

    user_attr = attributes_for(:user)
    within('#new_user') do
      fill_in 'user_email', with: user_attr[:email]
      fill_in 'user_password', with: user_attr[:password]
      fill_in 'user_password_confirmation', with: user_attr[:password]
      click_button 'Sign up'
    end

    expect(page).to have_current_path setup_users_path
    click_button 'Next'

    profile_attr = attributes_for(:profile)
    within('form') do
      fill_in 'profile_profileable_attributes_first_name', with: user_attr[:first_name]
      fill_in 'profile_profileable_attributes_last_name', with: user_attr[:last_name]
      fill_in 'profile_about', with: profile_attr[:about]
      click_button 'Next'
    end

    click_button 'btn-neutral'

    expect(page).to have_css('.btn-neutral[data-voted-on=true]')
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
    expect(page).to have_current_path motion_path(motion)
    expect(page).to have_content(motion.title)
    expect(page).to have_content(motion.content)

    click_link question.title
    expect(page).to have_current_path question_path(question)
    expect(page).to have_content(question.title)
    expect(page).to have_content(question.content)

    expect(page).not_to have_content(freetown.display_name)
  end

  scenario 'user should not visit forum show' do
    login_as(user, scope: :user)

    visit forum_path(freetown)

    expect(page).not_to have_content(freetown.display_name)
    expect(page).to have_current_path(forum_path(default))
  end

  scenario 'user should not see comment section' do
    login_as(user, scope: :user)

    visit argument_path(argument)

    expect(page).not_to have_content('Reply')
    expect(page).not_to have_content('Comments')
  end

  scenario 'user should vote on a motion' do
    login_as(user, scope: :user)

    visit motion_path(motion)
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-pro[data-voted-on=true]')
    find('.btn-pro').click
    expect(page).to have_css('.btn-pro[data-voted-on=true]')

    visit motion_path(motion)
    expect(page).to have_css('.btn-pro[data-voted-on=true]')
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
    expect(page).to have_current_path motion_path(motion)
    expect(page).to have_content(motion.title)
    expect(page).to have_content(motion.content)
    expect(page.body).not_to have_content('Start a new discussion')

    click_link question.title
    expect(page).to have_current_path question_path(question)
    expect(page).to have_content(question.title)
    expect(page).to have_content(question.content)

    expect(page).not_to have_content(freetown.display_name)
  end

  scenario 'member should not visit forum show' do
    login_as(member, scope: :user)

    visit forum_path(freetown)

    expect(page).not_to have_content(freetown.display_name)
    expect(page).to have_current_path(forum_path(default))
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

  scenario 'member should vote on a motion' do
    nominatim_netherlands

    login_as(member, scope: :user)

    visit motion_path(motion)
    expect(page).to have_content(motion.content)

    expect(page).not_to have_css('.btn-pro[data-voted-on=true]')
    find('.btn-pro').click
    expect(page).to have_css('.btn-pro[data-voted-on=true]')

    visit motion_path(motion)
    expect(page).to have_css('.btn-pro[data-voted-on=true]')
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
    expect(page).to have_current_path motion_path(motion)
    expect(page).to have_content(motion.title)
    expect(page).to have_content(motion.content)

    click_link question.title
    expect(page).to have_current_path question_path(question)
    expect(page).to have_content(question.title)
    expect(page).to have_content(question.content)

    click_link freetown.display_name
    expect(page).to have_current_path forum_path(freetown)
    expect(page).to have_content(freetown.display_name)
    expect(page).to have_content(freetown.bio)
    expect(page).to have_content('Forum settings')
  end

  scenario 'manager should visit forum show' do
    login_as(manager, scope: :user)

    visit forum_path(freetown)

    expect(page).to have_content(freetown.display_name)
    expect(page).to have_content(freetown.bio)
    expect(page).to have_current_path(forum_path(freetown))
  end

  scenario 'manager should not see comment section' do
    login_as(manager, scope: :user)

    visit argument_path(argument)

    expect(page.body).not_to have_content('Reply')
    expect(page.body).not_to have_content('Comments')
  end
end
