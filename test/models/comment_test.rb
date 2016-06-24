require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown.edge) }
  let(:argument) { create(:argument, parent: motion.edge) }
  subject { create(:comment, commentable: argument, parent: argument.edge) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end
end
