require 'test_helper'

class CreateCommentTest < ActiveSupport::TestCase

  let!(:freetown) { FactoryGirl.create :forum }
  let(:user) { create_member(freetown) }
  let(:commentable) { FactoryGirl.create(:argument,
                                         forum: freetown) }
  let(:comment_attributes) { attributes_for(:comment)
                                 .merge({commentable: commentable}) }

  test 'it creates a comment' do
    c = CreateComment.new(user.profile,
                          comment_attributes)
    assert c.resource.valid?
    assert_equal user.profile, c.resource.creator
    assert_broadcast(:create_comment_successful) do
      c.commit
    end
  end

end
