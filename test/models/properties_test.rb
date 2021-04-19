# frozen_string_literal: true

require 'test_helper'

class PropertiesTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength
  define_freetown
  define_freetown('second')
  let(:second_page) { create_page }
  let(:motion) { create(:motion, parent: freetown) }
  let(:comment) { create(:comment, parent: motion) }
  let(:parent_comment) { create(:comment, parent: motion) }
  let(:reply1) { create(:comment, parent: motion, in_reply_to_id: parent_comment.uuid) }
  let(:reply2) { create(:comment, parent: motion, in_reply_to_id: parent_comment.uuid) }
  let(:intervention_type) { create(:intervention_type, parent: argu) }
  let(:intervention) { create(:intervention, parent: intervention_type) }
  let(:measure) { create(:measure, parent: argu) }
  let(:tagged_measure) { create(:measure, parent: argu, phases: [term1, term2]) }
  let(:vocabulary) { create(:vocabulary, parent: argu) }
  let(:term1) { create(:term, parent: vocabulary) }
  let(:term2) { create(:term, parent: vocabulary) }

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
    assert_empty intervention.communication
    assert_difference('Property.count' => 2) do
      intervention.update!(communication: %i[open_communication communication_processed])
    end
    prop_id = intervention.property_manager(NS::RIVM[:communication]).send(:properties).first.id
    assert_difference('Property.count' => 0) do
      intervention.update!(communication: %i[open_communication communication_processed])
    end
    assert_equal %w[open_communication communication_processed], reloaded_intervention.communication
    assert_equal prop_id, intervention.property_manager(NS::RIVM[:communication]).send(:properties).first.id

    assert_difference('Property.count' => -1) do
      intervention.update!(communication: %i[open_communication])
    end
    assert_not_equal prop_id, intervention.property_manager(NS::RIVM[:communication]).send(:properties).first.id
    prop_id = intervention.property_manager(NS::RIVM[:communication]).send(:properties).first.id
    assert_difference('Property.count' => 0) do
      intervention.update!(communication: %i[open_communication])
    end
    assert_equal prop_id, intervention.property_manager(NS::RIVM[:communication]).send(:properties).first.id
    assert_equal %w[open_communication], reloaded_intervention.communication
  end

  test 'property array assignment with non array' do
    intervention
    assert_difference('Property.count' => 1) do
      intervention.update!(communication: :open_communication)
    end
    prop_id = intervention.property_manager(NS::RIVM[:communication]).send(:properties).first.id
    assert_difference('Property.count' => 0) do
      intervention.update!(communication: %i[open_communication])
    end
    assert_equal prop_id, intervention.property_manager(NS::RIVM[:communication]).send(:properties).first.id
    assert_equal %w[open_communication], reloaded_intervention.communication
  end

  test 'property has_one association' do
    [reply1, reply2].each do |reply|
      assert_equal parent_comment, reply.parent_comment
    end

    assert_equal [reply1, reply2], parent_comment.comments.order(:id)
  end

  test 'property has_one assignment by record' do
    comment.parent_comment = parent_comment
    assert_equal parent_comment, comment.parent_comment
    comment.save
    assert_equal parent_comment, comment.reload.parent_comment
  end

  test 'property has_one assignment by id' do
    comment.in_reply_to_id = parent_comment.uuid
    comment.save
    assert_equal parent_comment, comment.reload.parent_comment
  end

  test 'property has_many association' do
    assert_equal [term1, term2], tagged_measure.phases.order(:id)
    assert_equal [term1.uuid, term2.uuid].sort, tagged_measure.phase_ids.sort
  end

  test 'property has_many assignment by records' do
    assert_empty measure.phases
    term1
    term2
    assert_difference('Property.count' => 2) do
      measure.phases = [term1, term2]
    end
    assert_difference('Property.count' => 0) do
      measure.save
    end
    assert_equal [term1, term2], measure.phases.order(:id)
    assert_equal [term1.uuid, term2.uuid].sort, measure.phase_ids.sort
    assert_difference('Property.count' => 0) do
      measure.phases = [term2, term1]
    end
    assert_difference('Property.count' => 0) do
      measure.save
    end
    assert_equal [term1, term2], measure.phases.order(:id)

    assert_equal [term1, term2], measure.reload.phases.order(:id)
  end

  test 'property has_many assignment by ids' do
    assert_empty measure.phases
    term1
    term2
    assert_difference('Property.count' => 2) do
      measure.phase_ids = [term1.uuid, term2.uuid]
    end
    assert_difference('Property.count' => 0) do
      measure.save
    end
    assert_equal [term1, term2], measure.phases.order(:id)
    assert_equal [term1.uuid, term2.uuid].sort, measure.phase_ids.sort
    assert_difference('Property.count' => 0) do
      measure.phase_ids = [term2.uuid, term1.uuid]
    end
    assert_difference('Property.count' => 0) do
      measure.save
    end
    assert_equal [term1, term2], measure.phases.order(:id)

    assert_equal [term1, term2], measure.reload.phases.order(:id)
  end

  test 'properties remain when destorying other page' do
    assert_not_nil freetown.default_decision_group
    second_page.destroy
    assert_not_nil freetown.reload.default_decision_group
  end

  test 'property destruction' do
    assert_not_nil freetown.default_decision_group
    Property.where(predicate: NS::ARGU[:defaultDecisionGroupId].to_s).destroy_all
    assert_nil freetown.reload.default_decision_group
  end

  test 'linked edge destruction' do
    assert_equal parent_comment, reply1.parent_comment
    assert_difference('reply1.properties.count' => -1) do
      parent_comment.destroy
    end
    assert_nil reply1.reload.parent_comment
  end

  private

  def reloaded_intervention
    Edge.find_by(uuid: intervention.uuid)
  end

  def reloaded_motion
    Edge.find_by(uuid: motion.uuid)
  end
end
