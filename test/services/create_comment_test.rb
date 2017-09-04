# frozen_string_literal: true

require 'test_helper'

class CreateCommentTest < ActiveSupport::TestCase
  define_freetown
  let(:user) { create_member(freetown) }
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:commentable) do
    create(:argument,
           parent: motion.edge)
  end
  let(:comment_attributes) do
    attributes_for(:comment)
  end
  let(:comment_options) do
    {
      creator: user.profile,
      publisher: user
    }
  end

  test 'it creates a comment' do
    c = CreateComment.new(
      commentable.edge,
      attributes: comment_attributes,
      options: comment_options
    )
    assert c.resource.valid?
    assert_equal user.profile, c.resource.creator
    assert_broadcast(:create_comment_successful) do
      c.commit
    end
  end
end
