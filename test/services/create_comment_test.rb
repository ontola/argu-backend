# frozen_string_literal: true

require 'test_helper'

class CreateCommentTest < ActiveSupport::TestCase
  define_freetown
  let(:user) { create_initiator(freetown) }
  let(:motion) { create(:motion, parent: freetown) }
  let(:commentable) do
    create(:pro_argument,
           parent: motion)
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
    ActsAsTenant.current_tenant = argu
    c = CreateComment.new(
      commentable,
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
