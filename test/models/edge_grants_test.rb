# frozen_string_literal: true
require 'test_helper'

class EdgeGrantsTest < ActiveSupport::TestCase
  define_freetown
  let(:question) { create(:question, parent: freetown.edge) }
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
        group: create(:group, parent: freetown.page.edge),
        edge: freetown.edge,
        grant_set: GrantSet.find_by(title: 'administrator')
      ).group
    )
  end
  let(:motion_creator_group_memberhip) do
    create(
      :group_membership,
      member: user.profile,
      parent: create(
        :grant,
        group: create(:group, parent: freetown.page.edge),
        edge: motion.edge,
        grant_set: GrantSet.find_by(title: 'creator')
      ).group
    )
  end

  test 'manager should update motion' do
    assert_empty motion.edge.granted_group_ids('Motion', 'update')
    forum_manager_group_membership
    motion_creator_group_memberhip
    assert_equal motion.reload.edge.granted_group_ids('Motion', 'update').sort, [
      forum_manager_group_membership.group.id,
      motion_creator_group_memberhip.group.id
    ].sort
  end

  test 'spectator with create motion grant on question should create motion in question' do

  end

  test 'spectator with create motion grant on question should not create motion in other question' do

  end

  test 'comment creator should not update child comment' do
  end
end
