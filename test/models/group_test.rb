require 'test_helper'

class GroupTest < ActiveSupport::TestCase

  def setup
    @group = create(:group)
  end

  test 'valid' do
    assert @group.valid?, @group.errors.to_a.join(',').to_s
  end

  test 'associated memberships and responses should be destroyed' do
    create(:group_membership, group: @group)
    create(:group_response, group: @group)

    assert_difference ['GroupMembership.count', 'GroupResponse.count'], -1 do
      @group.destroy
    end
  end

end
