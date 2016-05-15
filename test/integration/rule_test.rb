require 'test_helper'

class RuleTest < ActionDispatch::IntegrationTest
  define_common_objects :freetown, :member, :manager, :owner

  def log_in_as(user, options = {})
    password    = options[:password]    || 'password'
    remember_me = options[:remember_me] || '1'

    post user_session_path,
         user: {
           email:       user.email,
           password:    password,
           remember_me: remember_me
         }
    assert_redirected_to root_path
  end

  def log_out
    get destroy_user_session_path
  end

  ####################################
  # As Member
  ####################################
  let(:member_argument) do
    create(:argument,
           forum: freetown,
           creator: member.profile)
  end
  let(:no_show_users) do
    create(:rule,
           context: freetown,
           action: 'show?',
           role: 'member',
           model_type: 'Argument',
           trickles: Rule.trickles[:trickles_down],
           message: 'user not allowed')
  end
  let(:no_show_managers) do
    create(:rule,
           context: freetown,
           action: 'show?',
           role: 'manager',
           model_type: 'Argument',
           trickles: Rule.trickles[:doesnt_trickle],
           message: 'ask your boss to buy')
  end
  let(:no_show_owners) do
    create(:rule,
           context: freetown,
           action: 'show?',
           role: 'owner',
           model_type: 'Argument',
           trickles: Rule.trickles[:doesnt_trickle],
           message: 'buy this feature')
  end

  test 'shows custom message' do
    no_show_users

    get argument_path(member_argument)
    assert_not_authorized
    assert_equal flash[:alert], 'user not allowed'
  end

  test 'shows appropriate message level to users' do
    no_show_users
    no_show_owners

    get argument_path(member_argument)
    assert_not_authorized
    assert_equal flash[:alert], 'user not allowed'
  end

  test 'shows appropriate message level to owners' do
    sign_in(manager)
    no_show_users
    no_show_managers

    get argument_path(member_argument)
    assert_not_authorized
    assert_equal flash[:alert], 'ask your boss to buy'
  end

  test 'shows the highest level message when multiple are active' do
    no_show_users
    no_show_owners
    no_show_managers

    [
      [member, 'user not allowed'],
      [manager, 'ask your boss to buy'],
      [owner, 'buy this feature']
    ].each do |user, message|
      sign_in(user)
      get argument_path(member_argument)
      assert_not_authorized
      assert_equal message, flash[:alert]
      log_out
    end
  end
end
