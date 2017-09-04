# frozen_string_literal: true

require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  include ModelTestBase

  define_freetown
  subject { create(:project, parent: freetown.edge) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
