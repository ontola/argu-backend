# frozen_string_literal: true

require 'test_helper'

class GrantTreeTest < ActiveSupport::TestCase
  define_freetown
  let(:question) { create(:question, parent: freetown) }
  let(:other_question) { create(:question, parent: freetown) }
  let(:motion) { create(:motion, parent: question) }
  let(:argument) { create(:pro_argument, parent: motion) }
  let(:comment) { create(:comment, parent: argument) }
  let(:nested_comment) { create(:comment, parent: argument, in_reply_to_id: subject.uuid) }
  let(:user) { create(:user) }
  let(:forum_manager_group_membership) do
    create(
      :group_membership,
      member: user.profile,
      parent: create(
        :grant,
        group: create(:group, parent: freetown.parent),
        edge: freetown,
        grant_set: GrantSet.administrator
      ).group
    )
  end
  let(:reset_motion_grants) { create(:grant_reset, edge: question, resource_type: 'Motion', action: 'create') }
  let(:public_create_motion_grant) do
    create(
      :grant,
      edge: question,
      group_id: Group::PUBLIC_ID,
      grant_set: GrantSet.for_one_action('Motion', 'create')
    )
  end

  test 'administrator group should update Motion' do
    assert_equal group_ids(motion, resource_type: 'Motion', action: 'update'),
                 [Group::STAFF_ID, argu.groups.first.id]
    forum_manager_group_membership
    assert_equal group_ids(motion, resource_type: 'Motion', action: 'update'),
                 [Group::STAFF_ID, argu.groups.first.id, forum_manager_group_membership.group.id].sort
  end

  test 'excluded group should not post Motion' do
    assert_equal group_ids(question, resource_type: 'Motion', action: 'create'),
                 [Group::STAFF_ID, Group::PUBLIC_ID, argu.groups.first.id]
    reset_motion_grants
    assert_empty group_ids(question, resource_type: 'Motion', action: 'create')
    assert_equal group_ids(other_question, resource_type: 'Motion', action: 'create'),
                 [Group::STAFF_ID, Group::PUBLIC_ID, argu.groups.first.id].sort
    public_create_motion_grant
    assert_equal group_ids(question, resource_type: 'Motion', action: 'create'),
                 [Group::PUBLIC_ID]
  end

  private

  def group_ids(edge, opts = {})
    GrantTree.new(freetown.root).granted_group_ids(edge, opts).sort
  end
end
