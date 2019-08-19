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
    motion
    name_id = motion.property_manager(NS::SCHEMA[:name]).send(:properties).first.id
    text_id = motion.property_manager(NS::SCHEMA[:text]).send(:properties).first.id

    assert_no_difference('Property.count') do
      motion.update!(description: 'New description')
    end

    assert_not_equal(text_id, reloaded_motion.property_manager(NS::SCHEMA[:text]).send(:properties).first.id)
    assert_equal(name_id, reloaded_motion.property_manager(NS::SCHEMA[:name]).send(:properties).first.id)
    assert_equal 'New description', reloaded_motion.description
    assert_equal 'New description', reloaded_motion.property_manager(NS::SCHEMA[:text]).value

    assert_no_difference('Property.count') do
      motion.update!(description: nil)
    end

    assert_nil reloaded_motion.description
    assert_nil reloaded_motion.property_manager(NS::SCHEMA[:text]).value
  end

  test 'property array assignment' do
    assert_empty intervention_type.example_of_id
    assert_empty intervention_type.example_of
    risk1
    risk2
    assert_difference('Property.count' => 2) do
      intervention_type.update!(example_of_id: [risk1.uuid, risk2.uuid])
    end
    assert_equal [risk1.uuid, risk2.uuid], reloaded_intervention_type.example_of_id
    assert_equal [risk1, risk2], reloaded_intervention_type.example_of
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

  private

  def reloaded_intervention_type
    Edge.find_by(uuid: intervention_type.uuid)
  end

  def reloaded_motion
    Edge.find_by(uuid: motion.uuid)
  end
end
