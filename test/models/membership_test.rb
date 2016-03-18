require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  subject { create(:membership) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
