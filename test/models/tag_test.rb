require 'test_helper'

class TagTest < ActiveSupport::TestCase

  def tag
    @tag ||= tags(:nature)
  end

  def test_valid
    assert tag.valid?, tag.errors.to_a.join(',').to_s
  end

end
