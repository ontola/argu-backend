require 'test_helper'

class PageMembershipTest < ActiveSupport::TestCase

  def page_membership
    @page_membership ||= page_memberships(:mem_utrecht)
  end

  def test_valid
    assert page_membership.valid?, page_membership.errors.to_a.join(',').to_s
  end

end
