# frozen_string_literal: true

require 'test_helper'

class RuleTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:freetown_administrator) { create_administrator(freetown) }
  let(:freetown_moderator) { create_moderator(freetown) }

  def log_out
    get destroy_user_session_path
  end

  ####################################
  # As Initiator
  ####################################
  let(:initiator) { create_initiator(freetown) }
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:initiator_argument) do
    create(:argument,
           parent: motion.edge,
           creator: initiator.profile)
  end
  let(:question1) { create(:question, parent: freetown.edge) }
  let(:question2) { create(:question, parent: freetown.edge) }
  let(:motion1) { create(:motion, parent: question1.edge) }
  let(:motion2) { create(:motion, parent: question2.edge) }
  let(:no_show_users) do
    create(:rule,
           branch: freetown.edge,
           action: 'show?',
           role: 'participator',
           model_type: 'Argument',
           trickles: Rule.trickles[:trickles_down],
           message: 'user not allowed')
  end

  let(:no_show_moderators) do
    create(:rule,
           branch: freetown.edge,
           action: 'show?',
           role: 'moderator',
           model_type: 'Argument',
           trickles: Rule.trickles[:doesnt_trickle],
           message: 'ask your boss to buy')
  end

  let(:no_show_administrators) do
    create(:rule,
           branch: freetown.edge,
           action: 'show?',
           role: 'administrator',
           model_type: 'Argument',
           trickles: Rule.trickles[:doesnt_trickle],
           message: 'buy this feature')
  end
  let(:no_show_motion_in_specific_question) do
    create(:rule,
           branch: question2.edge,
           action: 'show?',
           role: 'moderator',
           model_type: 'Motion',
           trickles: Rule.trickles[:doesnt_trickle],
           message: 'showing motions not allowed')
  end

  test 'shows custom message' do
    no_show_users

    get argument_path(initiator_argument)
    assert_not_authorized
    assert_equal flash[:alert], 'user not allowed'
  end

  test 'shows appropriate message level to users' do
    no_show_users
    no_show_administrators

    get argument_path(initiator_argument)
    assert_not_authorized
    assert_equal flash[:alert], 'user not allowed'
  end

  test 'shows appropriate message level to administrators' do
    sign_in(freetown_moderator)
    no_show_users
    no_show_moderators

    get argument_path(initiator_argument)
    assert_not_authorized
    assert_equal flash[:alert], 'ask your boss to buy'
  end

  test 'shows the highest level message when multiple are active' do
    no_show_users
    no_show_administrators
    no_show_moderators

    [
      [initiator, 'user not allowed'],
      [freetown_moderator, 'ask your boss to buy'],
      [freetown_administrator, 'buy this feature']
    ].each do |user, message|
      sign_in(user)
      get argument_path(initiator_argument)
      assert_not_authorized
      assert_equal message, flash[:alert]
      log_out
    end
  end

  test 'hide motions for specific question' do
    no_show_motion_in_specific_question
    sign_in freetown_moderator

    get motion_path(motion1)
    assert_response 200
    assert_nil flash[:alert]

    get motion_path(motion2)
    assert_not_authorized
    assert_equal flash[:alert], 'showing motions not allowed'
  end
end
