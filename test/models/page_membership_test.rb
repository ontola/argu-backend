require 'test_helper'

class PageMembershipTest < ActiveSupport::TestCase
  subject { create(:page_membership) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
