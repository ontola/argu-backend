# frozen_string_literal: true

require 'test_helper'

class DecisionsTest < ActionDispatch::IntegrationTest
  define_freetown
  let!(:administrator) { create_administrator(freetown) }
  let(:group_membership) do
    create(:group_membership,
           parent: create(:group, parent: argu))
  end
  let(:actor_membership) do
    create(:group_membership,
           parent: create(:group, parent: argu),
           member: actor.profile)
  end
  let!(:motion) do
    create(:motion,
           parent: freetown)
  end
  let!(:forward) do
    create(:decision,
           parent: motion,
           publisher: creator,
           forwarded_user: actor,
           forwarded_group: actor_membership.group,
           state: Decision.states[:forwarded])
  end
  let(:approval) do
    create(:decision,
           parent: motion,
           publisher: creator,
           state: Decision.states[:approved])
  end
  let(:creator) { create_initiator(freetown) }

  ####################################
  # As Actor
  ####################################
  let(:actor) { create_initiator(freetown) }
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
           parent: motion,
           argu_publication_attributes: {
             draft: true
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
    general_forward 200, false, create(:group, parent: argu).id, create(:user).id
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
  let(:user) { create(:user) }
  test 'group_member should post approve' do
    sign_in user
    create(:group_membership,
           group_id: create(:group, parent: motion.ancestor(:page)).id,
           member: user.profile)
    create(:decision,
           parent: motion,
           publisher: creator,
           forwarded_user: nil,
           forwarded_group: Group.last,
           state: Decision.states[:forwarded])
    general_decide 302, true
  end

  ####################################
  # As Moderator
  ####################################
  let(:moderator) { create_moderator freetown }

  test 'moderator should get show' do
    sign_in moderator
    general_show
  end

  test 'moderator should not post approve' do
    sign_in moderator
    general_decide 403, false
  end

  test 'moderator should not post reject' do
    sign_in moderator
    general_decide 403, false, 'rejected'
  end

  test 'moderator should post forward' do
    sign_in moderator
    general_forward 302, true, group_membership.group.id, group_membership.member.profileable_id
  end

  test 'moderator should patch update approved' do
    sign_in moderator
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

    get collection_iri_path(record, :decisions)
    assert_response response
  end

  def general_decide(response = 302, changed = false, state = 'approved')
    assert_difference('Activity.count' => changed ? 1 : 0) do
      post  collection_iri_path(motion, :decisions),
            params: {
              decision: attributes_for(:decision,
                                       state: state,
                                       content: 'Content')
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
    assert_difference('Activity.count' => changed ? 1 : 0,
                      'Decision.count' => changed ? 1 : 0) do
      post collection_iri_path(motion, :decisions),
           params: {
             decision: attributes_for(:decision,
                                      decisionable: motion,
                                      state: 'forwarded',
                                      content: 'Content',
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
    assert_difference('Decision.count' => 0, 'Activity.count' => changed ? 1 : 0) do
      put decision.iri_path,
          params: {
            decision: attributes_for(:decision,
                                     decisionable: motion,
                                     content: 'Changed content')
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
