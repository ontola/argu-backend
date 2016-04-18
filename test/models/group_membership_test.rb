require 'test_helper'

class GroupMembershipTest < ActiveSupport::TestCase
  define_freetown
  let(:user) { create(:user) }
  subject { create(:group_membership, parent: freetown.members_group, member: user.profile) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
