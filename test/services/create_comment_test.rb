require 'test_helper'

class CreateCommentTest < ActiveSupport::TestCase
  let!(:freetown) { create :forum }
  let(:user) { create_member(freetown) }
  let(:commentable) do
    create(:argument,
           forum: freetown)
  end
  let(:comment_attributes) do
    attributes_for(:comment)
      .merge(commentable: commentable)
  end
  let(:comment_options) do
    {
      creator: user.profile,
      publisher: user
    }
  end

  test 'it creates a comment' do
    c = CreateComment.new(Comment.new,
                          comment_attributes,
                          comment_options)
    assert c.resource.valid?
    assert_equal user.profile, c.resource.creator
    assert_broadcast(:create_comment_successful) do
      c.commit
    end
  end
end
