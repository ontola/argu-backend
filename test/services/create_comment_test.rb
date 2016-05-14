require 'test_helper'

class CreateCommentTest < ActiveSupport::TestCase
  define_common_objects :freetown!, :member
  let(:commentable) do
    create(:argument,
           forum: freetown)
  end
  let(:comment_attributes) do
    attributes_for(:comment, creator: member.profile)
      .merge(commentable: commentable)
  end

  test 'it creates a comment' do
    c = CreateComment.new(Comment.new,
                          comment_attributes)
    assert c.resource.valid?
    assert_equal member.profile, c.resource.creator
    assert_broadcast(:create_comment_successful) do
      c.commit
    end
  end
end
