require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  include ModelTestBase

  let(:freetown) { create(:forum) }
  subject { create(:project, forum: freetown) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
