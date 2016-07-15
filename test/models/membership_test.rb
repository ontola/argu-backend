# frozen_string_literal: true
require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  define_freetown
  let(:user) { create(:user) }
  subject { create(:membership, profile: user.profile, parent: freetown.edge) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
