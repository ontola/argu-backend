require 'test_helper'

class ArgumentTest < ActiveSupport::TestCase

  subject { FactoryGirl.create(:argument) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  def test_comment_increases_interactions_count
    assert_equal 2, subject.interactions_count
    comment = FactoryGirl.create(:comment, commentable: subject)
    assert_equal 3, subject.interactions_count
    c = FactoryGirl.create(:comment, commentable: subject)
    c.move_to_child_of(comment)
    assert_equal 4, subject.interactions_count
  end

end
