require "test_helper"

class MembershipTest < ActiveSupport::TestCase

  def membership
    @membership ||= memberships(:user_utrecht)
  end

  def test_valid
    assert membership.valid?, membership.errors.to_a.join(',').to_s
  end

end
