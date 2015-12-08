require 'test_helper'

class PageMembershipTest < ActiveSupport::TestCase

  subject { FactoryGirl.create(:page_membership) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

end
