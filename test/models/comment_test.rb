require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  subject { FactoryGirl.create(:comment) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

end
