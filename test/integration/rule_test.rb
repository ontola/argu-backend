# frozen_string_literal: true
require 'test_helper'

class RuleTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:freetown_owner) { create_owner(freetown) }
  let(:freetown_manager) { create_manager(freetown) }

  def log_out
    get destroy_user_session_path
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:member_argument) do
    create(:argument,
           parent: motion.edge,
           creator: member.profile)
  end
  let(:question1) { create(:question, parent: freetown.edge) }
  let(:question2) { create(:question, parent: freetown.edge) }
  let(:motion1) { create(:motion, parent: question1.edge) }
  let(:motion2) { create(:motion, parent: question2.edge) }
  let(:no_show_users) do
    create(:rule,
           branch: freetown.edge,
           action: 'show?',
           role: 'member',
           model_type: 'Argument',
           trickles: Rule.trickles[:trickles_down],
           message: 'user not allowed')
  end

  let(:no_show_managers) do
    create(:rule,
           branch: freetown.edge,
           action: 'show?',
           role: 'manager',
           model_type: 'Argument',
           trickles: Rule.trickles[:doesnt_trickle],
           message: 'ask your boss to buy')
  end

  let(:no_show_owners) do
    create(:rule,
           branch: freetown.edge,
           action: 'show?',
           role: 'owner',
           model_type: 'Argument',
           trickles: Rule.trickles[:doesnt_trickle],
           message: 'buy this feature')
  end
  let(:no_show_motion_in_specific_question) do
    create(:rule,
           branch: question2.edge,
           action: 'show?',
           role: 'manager',
           model_type: 'Motion',
           trickles: Rule.trickles[:doesnt_trickle],
           message: 'showing motions not allowed')
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
    sign_in(freetown_manager)
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
      [freetown_manager, 'ask your boss to buy'],
      [freetown_owner, 'buy this feature']
    ].each do |user, message|
      sign_in(user)
      get argument_path(member_argument)
      assert_not_authorized
      assert_equal message, flash[:alert]
      log_out
    end
  end

  test 'hide motions for specific question' do
    no_show_motion_in_specific_question
    sign_in freetown_manager

    get motion_path(motion1)
    assert_response 200
    assert_nil flash[:alert]

    get motion_path(motion2)
    assert_not_authorized
    assert_equal flash[:alert], 'showing motions not allowed'
  end
end
