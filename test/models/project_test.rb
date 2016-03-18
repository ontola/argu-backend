require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  include ModelTestBase

  subject { create(:project) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

end
