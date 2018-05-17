# frozen_string_literal: true

require 'test_helper'

class GrantTreeTest < ActiveSupport::TestCase
  define_freetown
  let(:question) { create(:question, parent: freetown.edge) }
  let(:other_question) { create(:question, parent: freetown.edge) }
  let(:motion) { create(:motion, parent: question.edge) }
  let(:argument) { create(:argument, parent: motion.edge) }
  let(:comment) { create(:comment, parent: argument.edge) }
  let(:nested_comment) { create(:comment, parent: argument.edge, parent_id: subject.id) }
  let(:user) { create(:user) }
  let(:forum_manager_group_membership) do
    create(
      :group_membership,
      member: user.profile,
      parent: create(
        :grant,
        group: create(:group, parent: freetown.parent_edge),
        edge: freetown.edge,
        grant_set: GrantSet.administrator
      ).group
    )
  end
  let(:reset_motion_grants) { create(:grant_reset, edge: question.edge, resource_type: 'Motion', action: 'create') }
  let(:public_create_motion_grant) do
    create(
      :grant,
      edge: question.edge,
      group_id: Group::PUBLIC_ID,
      grant_set: GrantSet.for_one_action('Motion', 'create')
    )
  end

  test 'administrator group should update Motion' do
    assert_equal group_ids(motion.edge, resource_type: 'Motion', action: 'update'),
                 [Group::STAFF_ID, argu.groups.first.id]
    forum_manager_group_membership
    assert_equal group_ids(motion.edge, resource_type: 'Motion', action: 'update'),
                 [Group::STAFF_ID, argu.groups.first.id, forum_manager_group_membership.group.id].sort
  end

  test 'excluded group should not post Motion' do
    assert_equal group_ids(question.edge, resource_type: 'Motion', action: 'create'),
                 [Group::STAFF_ID, Group::PUBLIC_ID, argu.groups.first.id]
    reset_motion_grants
    assert_empty group_ids(question.edge, resource_type: 'Motion', action: 'create')
    assert_equal group_ids(other_question.edge, resource_type: 'Motion', action: 'create'),
                 [Group::STAFF_ID, Group::PUBLIC_ID, argu.groups.first.id].sort
    public_create_motion_grant
    assert_equal group_ids(question.edge, resource_type: 'Motion', action: 'create'),
                 [Group::PUBLIC_ID]
  end

  private

  def group_ids(edge, opts = {})
    GrantTree.new(freetown.edge.root).granted_group_ids(edge, opts).sort
  end
end
