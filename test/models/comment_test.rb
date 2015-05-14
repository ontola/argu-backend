require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  def comment
    @comment ||= comments(:one)
  end

  def test_valid
    assert comment.valid?, comment.errors.to_a.join(',').to_s
  end

end
