# frozen_string_literal: true

require 'test_helper'

class PropertiesTest < ActiveSupport::TestCase
  define_freetown
  define_freetown('second')
  let(:second_page) { create_page }
  let(:motion) { create(:motion, parent: freetown) }
  let(:parent_comment) { create(:comment, parent: motion) }
  let(:reply1) { create(:comment, parent: motion, in_reply_to_id: parent_comment.uuid) }
  let(:reply2) { create(:comment, parent: motion, in_reply_to_id: parent_comment.uuid) }
  let(:risk1) { create(:risk, parent: argu) }
  let(:risk2) { create(:risk, parent: argu) }
  let(:intervention_type) { create(:intervention_type, parent: argu) }

  test 'property assignment' do
    motion.update!(description: 'New name')
    assert_equal 'New name', Edge.find_by(uuid: motion.uuid).description
    assert_equal 'New name', Edge.find_by(uuid: motion.uuid).property_instance(NS::SCHEMA[:text]).text
    motion.update!(description: nil)
    assert_equal nil, Edge.find_by(uuid: motion.uuid).description
    assert_equal nil, Edge.find_by(uuid: motion.uuid).property_instance(NS::SCHEMA[:text]).text
  end

  test 'property associations' do
    [reply1, reply2].each do |reply|
      assert_equal parent_comment, reply.parent_comment
    end

    assert_equal [reply1, reply2], parent_comment.comment_children
  end

  test 'property destruction' do
    assert_not_nil freetown.default_decision_group
    second_page.destroy
    assert_not_nil freetown.reload.default_decision_group
  end
end
