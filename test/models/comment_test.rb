require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  subject { FactoryGirl.create(:comment) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  def test_followers_increase_interactions_count
    assert_equal 0, subject.interactions_count
    FactoryGirl.create(:follow, followable: subject)
    assert_equal 1, subject.reload.interactions_count
    FactoryGirl.create(:follow, followable: subject)
    assert_equal 2, subject.interactions_count
  end

end
