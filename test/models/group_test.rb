require 'test_helper'

class GroupTest < ActiveSupport::TestCase

  subject { FactoryGirl.create(:group) }

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'associated memberships and responses should be destroyed' do
    FactoryGirl.create(:group_membership, group: subject)
    FactoryGirl.create(:group_response, group: subject)

    assert_difference ['GroupMembership.count', 'GroupResponse.count'], -1 do
      subject.destroy
    end
  end

end
