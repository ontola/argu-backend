# frozen_string_literal: true
require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  define_freetown
  subject { create(:group, parent: freetown.edge) }
  let(:motion) { create(:motion, parent: freetown.edge) }

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'associated memberships and responses should be destroyed' do
    create(:group_membership,
           group: subject)
    create(:group_response,
           group: subject,
           parent: motion.edge)

    assert_difference ['GroupMembership.count', 'GroupResponse.count'], -1 do
      subject.destroy
    end
  end
end
