# frozen_string_literal: true
require 'test_helper'

class DecisionsTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:super_admin) { create_super_admin(freetown) }
  let(:group_membership) do
    create(:group_membership,
           parent: create(:group, parent: freetown.page.edge))
  end
  let(:actor_membership) do
    create(:group_membership,
           parent: create(:group, parent: freetown.page.edge),
           member: actor.profile)
  end
  let!(:motion) do
    create(:motion,
           parent: freetown.edge)
  end
  let!(:forward) do
    create(:decision,
           parent: motion.edge,
           happening_attributes: {
             happened_at: DateTime.current
           },
           publisher: creator,
           forwarded_user: actor,
           forwarded_group: actor_membership.group,
           state: Decision.states[:forwarded])
  end
  let(:approval) do
    create(:decision,
           parent: motion.edge,
           happening_attributes: {
             happened_at: DateTime.current
           },
           publisher: creator,
           state: Decision.states[:approved])
  end

  ####################################
  # As Guest
  ####################################

  test 'guest should get show' do
    general_show
  end

  test 'guest should not get show draft' do
    general_show
  end

  test 'guest should not post approve' do
    general_decide
  end

  ####################################
  # As User
  ####################################
  let(:user) { create(:user) }

  test 'user should get show' do
    sign_in user
    general_show
  end

  test 'user should not post approve' do
    sign_in user
    general_decide 403
    assert_not_authorized
  end

  test 'user should not patch update approved' do
    sign_in user
    general_update_approved 403, false
    assert_not_authorized
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should get show' do
    sign_in member
    general_show
  end

  test 'member should not post approve' do
    sign_in member
    general_decide 403
  end

  test 'member should not patch update approved' do
    sign_in member
    general_update_approved 403, false
  end

  ####################################
  # As Creator
  ####################################
  let(:creator) { create_member(freetown) }

  test 'creator should patch update approved' do
    sign_in creator
    general_update_approved 302, true
  end

  ####################################
  # As Actor
  ####################################
  let(:actor) { create_member(freetown) }
  test 'actor should post approve' do
    sign_in actor
    general_decide 302, true
  end

  test 'actor should post reject' do
    sign_in actor
    general_decide 302, true, 'rejected'
  end

  test 'actor should not post approve when draft is present' do
    create(:decision,
           parent: motion.edge,
           happening_attributes: {
             happened_at: DateTime.current
           },
           edge_attributes: {
             argu_publication_attributes: {
               draft: true
             }
           },
           publisher: creator,
           forwarded_user: actor,
           forwarded_group: actor_membership.group,
           state: Decision.states[:forwarded])
    sign_in actor

    general_decide 403, false
  end

  test 'actor should not post forward to nil' do
    sign_in actor
    general_forward 200, false
  end

  test 'actor should not post forward to user/group without membership' do
    sign_in actor
    general_forward 200, false, create(:group, parent: freetown.page.edge).id, create(:user).id
  end

  test 'actor should post forward' do
    sign_in actor
    general_forward 302, true, group_membership.group.id, group_membership.member.profileable_id
  end

  test 'actor should not patch update approved' do
    sign_in actor
    general_update_approved 403, false
  end

  ####################################
  # As GroupMember
  ####################################
  test 'group_member should post approve' do
    sign_in member
    create(:group_membership,
           group_id: create(:group, parent: motion.forum.page.edge).id,
           member: member.profile)
    create(:decision,
           parent: motion.edge,
           happening_attributes: {
             happened_at: DateTime.current
           },
           publisher: creator,
           forwarded_user: nil,
           forwarded_group: Group.last,
           state: Decision.states[:forwarded])
    general_decide 302, true
  end

  ####################################
  # As Manager
  ####################################
  let(:manager) { create_manager freetown }

  test 'manager should get show' do
    sign_in manager
    general_show
  end

  test 'manager should not post approve' do
    sign_in manager
    general_decide 403, false
  end

  test 'manager should not post reject' do
    sign_in manager
    general_decide 403, false, 'rejected'
  end

  test 'manager should post forward' do
    sign_in manager
    general_forward 302, true, group_membership.group.id, group_membership.member.profileable_id
  end

  test 'manager should patch update approved' do
    sign_in manager
    general_update_approved 302, true
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create :user, :staff }

  test 'staff should get show' do
    sign_in staff
    general_show
  end

  test 'staff should not post update approve' do
    sign_in staff
    general_decide 403, false
  end

  test 'staff should not post update rejected' do
    sign_in staff
    general_decide 403, false, 'rejected'
  end

  test 'staff should post forward' do
    sign_in staff
    general_forward 302, true, group_membership.group.id, group_membership.member.profileable_id
  end

  test 'staff should patch update approved' do
    sign_in staff
    general_update_approved 302, true
  end

  private

  ####################################
  # Guest, User, Member share features
  ####################################

  def general_show(response = 200, record = motion)
    approval

    get motion_decisions_path(record)
    assert_response response

    # Temporary check to see if old urls still work
    get motion_decisions_path(record.edge)
    assert_response response
  end

  def general_decide(response = 302, changed = false, state = 'approved')
    assert_differences([['Activity.count', changed ? 2 : 0]]) do
      post  motion_decisions_path(motion),
            params: {
              decision: attributes_for(:decision,
                                       state: state,
                                       content: 'Content',
                                       happening_attributes: {happened_at: Time.current})
            }
    end
    reset_publication(Publication.last)

    if changed
      motion.reload
      assert_equal state, motion.state
      assert_equal state, Decision.last.activities.last.action
      assert_equal 'news', Decision.last.activities.last.follow_type
    else
      assert_equal motion.state, 'pending'
    end
    assert_response response
  end

  def general_forward(response = 302, changed = false, group_id = nil, user_id = nil)
    assert_differences([['Activity.count', changed ? 2 : 0],
                        ['Decision.count', changed ? 1 : 0]]) do
      post motion_decisions_path(motion),
           params: {
             decision: attributes_for(:decision,
                                      decisionable: motion,
                                      state: 'forwarded',
                                      content: 'Content',
                                      happening_attributes: {happened_at: Time.current},
                                      forwarded_user_id: user_id,
                                      forwarded_group_id: group_id)
           }
    end
    reset_publication(Publication.last)
    assert_response response
    assert_equal 'reactions', Decision.last.activities.last.follow_type if changed
  end

  def general_update_approved(response = 302, changed = false)
    ch_method = method(changed ? :assert_not_equal : :assert_equal)
    approval
    decision = motion.reload.last_decision
    assert_differences([['Decision.count', 0], ['Activity.count', changed ? 1 : 0]]) do
      put motion_decision_path(motion.edge, decision.step),
          params: {
            decision: attributes_for(:decision,
                                     decisionable: motion,
                                     content: 'Changed content',
                                     happening_attributes: {
                                       id: decision.happening.id,
                                       happened_at: Time.current
                                     })
          }
    end
    motion.reload
    assert_equal 'approved', motion.state
    assert_response response
    if assigns(:update_service).try(:resource).present?
      ch_method.call decision
        .updated_at
        .utc
        .iso8601(6),
                     assigns(:update_service)
        .try(:resource)
        .try(:updated_at)
        .try(:utc)
        .try(:iso8601, 6)
    elsif changed
      assert false, 'Model changed when it should not have'
    end
    return unless changed
    assert_equal 'Changed content', decision.reload.content
    assert_equal 'update', decision.activities.last.action
  end
end
