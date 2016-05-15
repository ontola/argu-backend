require 'test_helper'

class CreateCommentTest < ActiveSupport::TestCase
  define_common_objects :freetown!, :member, :argument
  let(:comment_attributes) do
    attributes_for(:comment, creator: member.profile)
      .merge(commentable: argument)
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
