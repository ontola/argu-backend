# frozen_string_literal: true

require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  define_freetown
  subject do
    ActsAsTenant.with_tenant(argu) do
      create(
        :activity,
        trackable: create(:motion, parent: freetown),
        trackable_type: 'Motion',
        recipient: freetown,
        recipient_type: 'Forum',
        root_id: freetown.root_id
      )
    end
  end

  def test_valid
    assert subject.valid?
  end
end
