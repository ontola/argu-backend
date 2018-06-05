# frozen_string_literal: true

require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  define_freetown
  subject { create(:group, parent: argu) }
  let(:motion) { create(:motion, parent: freetown) }

  test 'valid' do
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'associated memberships should be destroyed' do
    create(:group_membership, parent: subject)

    assert_difference ['GroupMembership.count'], -1 do
      subject.destroy
    end
  end
end
