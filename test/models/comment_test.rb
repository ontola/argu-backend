# frozen_string_literal: true
require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:argument) { create(:argument, parent: motion.edge) }
  let(:nested_comment) { create(:comment, parent: argument.edge, parent_id: subject.id) }
  subject { create(:comment, parent: argument.edge) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'destroy nested comments when destroying parent' do
    nested_comment
    assert_difference('Comment.count', -2) do
      DestroyService
        .new(motion, options: {creator: motion.creator, publisher: motion.publisher})
        .commit
    end
  end
end
