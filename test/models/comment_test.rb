# frozen_string_literal: true

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }
  let(:argument) { create(:pro_argument, parent: motion) }
  let(:nested_comment) { create(:comment, parent: argument, in_reply_to_id: subject.uuid) }
  subject { create(:comment, parent: argument) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'destroy nested comments when destroying parent' do
    ActsAsTenant.current_tenant = motion.root
    nested_comment
    assert_difference('Comment.count', -2) do
      DestroyService
        .new(motion, options: {creator: motion.creator, publisher: motion.publisher})
        .commit
    end
  end
end
