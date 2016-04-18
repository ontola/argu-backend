require 'test_helper'

class DecisionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  define_freetown
  let!(:owner) { create(:user) }
  let!(:page) { create(:page, owner: owner.profile) }
  let!(:moderator) { create_member(freetown) }
  let(:group_membership) do
    create(:group_membership,
           parent: create(:group, parent: freetown.page.edge).edge)
  end
  let(:actor_membership) do
    create(:group_membership,
           parent: create(:group, parent: freetown.page.edge).edge,
           member: actor.profile)
  end
  let!(:motion) do
    create(:motion,
           traits_with_args: {
             assigned: {
               assigned_to_group: actor_membership.group,
               assigned_to_user: actor
             }
           },
           parent: freetown.edge)
  end
  let!(:approved_motion) do
    create(:motion,
           :approved,
           traits_with_args: {
             assigned: {
               assigned_to_group: actor_membership.group,
               assigned_to_user: actor
             }
           },
           parent: freetown.edge)
  end

  ####################################
  # As Guest
  ####################################

  test 'guest should get show' do
    general_show
  end

  test 'guest should not patch approve' do
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

  test 'user should not patch approve' do
    sign_in user
    general_decide 403
  end

  ####################################
  # As Member
  ####################################
  let(:member) { create_member(freetown) }

  test 'member should get show' do
    sign_in member
    general_show
  end

  test 'member should not patch approve' do
    sign_in member
    general_decide
  end

  ####################################
  # As Actor
  ####################################
  let(:actor) { create_member(freetown) }
  test 'actor should patch approve' do
    sign_in actor
    general_decide 302, true
  end

  test 'actor should patch reject' do
    sign_in actor
    general_decide 302, true, 'rejected'
  end

  test 'actor should not patch forward to nil' do
    sign_in actor
    general_forward 200, false
  end

  test 'actor should not patch forward to user/group without membership' do
    sign_in actor
    general_forward 200, false, create(:group, parent: freetown.page.edge).id, create(:user).id
  end

  test 'actor should patch forward' do
    sign_in actor
    general_forward 302, true, group_membership.group.id, group_membership.member.profileable_id
  end

  test 'actor should patch update approved' do
    sign_in actor
    general_update_approved 302, true
  end

  ####################################
  # As GroupMember
  ####################################
  test 'group_member should patch approve' do
    sign_in member
    create(:group_membership,
           parent: create(:group, parent: motion.forum.page.edge).edge,
           member: member.profile)
    motion.last_decision.update_columns(group_id: Group.last.id, user_id: nil)
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

  test 'manager should not patch approve' do
    sign_in manager
    general_decide 302, false
  end

  test 'manager should not patch reject' do
    sign_in manager
    general_decide 302, false, 'rejected'
  end

  test 'manager should patch forward' do
    sign_in manager
    general_forward 302, true, group_membership.group.id, group_membership.member.profileable_id
  end

  ####################################
  # As Staff
  ####################################
  let(:staff) { create :user, :staff }

  test 'staff should get show' do
    sign_in staff
    general_show
  end

  test 'staff should not patch update approve' do
    sign_in staff
    general_decide 302, false
  end

  test 'staff should not patch update rejected' do
    sign_in staff
    general_decide 302, false, 'rejected'
  end

  test 'staff should patch forward' do
    sign_in staff
    general_forward 302, true, group_membership.group.id, group_membership.member.profileable_id
  end

  private

  ####################################
  # Guest, User, Member share features
  ####################################

  def general_show(response = 200, record = motion)
    get :show,
        id: record.last_decision

    assert_redirected_to motion_decisions_url(record)
  end

  def general_decide(response = 302, changed = false, state = 'approved')
    ch_method = method(changed ? :assert_not_equal : :assert_equal)
    decision = motion.last_decision

    assert_differences([['Activity.count', changed ? 2 : 0]]) do
      patch :update,
            id: decision,
            decision: attributes_for(:decision,
                                     state: state,
                                     content: 'Content',
                                     happening_attributes: {happened_at: Time.current})
    end
    if changed
      motion.reload
      assert_equal state, motion.state
      assert_equal state, decision.activities.last.action
    else
      assert_equal motion.state, 'pending'
    end
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
  end

  def general_forward(response = 302, changed = false, group_id = nil, user_id = nil)
    ch_method = method(changed ? :assert_not_equal : :assert_equal)
    decision = motion.last_decision

    assert_differences([['Activity.count', changed ? 2 : 0],
                        ['Decision.count', changed ? 1 : 0]]) do
      patch :update,
            id: decision,
            decision: attributes_for(:decision,
                                     decisionable: motion,
                                     state: 'forwarded',
                                     content: 'Content',
                                     happening_attributes: {happened_at: Time.current},
                                     forwarded_to_attributes: {
                                       user_id: user_id,
                                       group_id: group_id})
    end
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
  end

  def general_update_approved(response = 302, changed = false)
    ch_method = method(changed ? :assert_not_equal : :assert_equal)
    decision = approved_motion.last_decision
    assert_differences([['Activity.count', changed ? 1 : 0]]) do
      patch :update,
            id: decision,
            decision: attributes_for(:decision,
                                     decisionable: motion,
                                     content: 'Changed content',
                                     happening_attributes: {happened_at: Time.current})
    end
    approved_motion.reload
    assert_equal 'approved', approved_motion.state
    assert_equal 'update', decision.activities.last.action
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
  end
end
