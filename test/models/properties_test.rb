# frozen_string_literal: true

require 'test_helper'

class PropertiesTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength
  define_freetown('freetown', attributes: {bio: 'Test'})
  define_freetown('second')
  let(:second_page) { create_page }
  let(:motion) { create(:motion, parent: freetown) }
  let(:comment) { create(:comment, parent: motion) }
  let(:parent_comment) { create(:comment, parent: motion) }
  let(:reply1) { create(:comment, parent: motion, parent_comment_id: parent_comment.uuid) }
  let(:reply2) { create(:comment, parent: motion, parent_comment_id: parent_comment.uuid) }
  let(:intervention_type) { create(:intervention_type, parent: argu) }
  let(:intervention) { create(:intervention, parent: intervention_type) }
  let(:measure) { create(:measure, parent: argu) }
  let(:tagged_measure) { create(:measure, parent: argu, phases: [term1, term2]) }
  let(:vocabulary) { create(:vocabulary, parent: argu) }
  let(:term1) { create(:term, parent: vocabulary) }
  let(:term2) { create(:term, parent: vocabulary) }

  test 'default properties' do
    assert_equal(
      create(:page).properties.where(predicate: NS.ontola[:template]).pluck(:string),
      %w[default]
    )

    assert_equal(
      create(:page, template: 'test').properties.where(predicate: NS.ontola[:template]).pluck(:string),
      %w[test]
    )
  end

  test 'property assignment' do
    motion
    name_id = motion.property_manager(NS.schema.name).send(:properties).first.id
    text_id = motion.property_manager(NS.schema.text).send(:properties).first.id

    assert_no_difference('Property.count') do
      motion.update!(description: 'New description')
    end

    assert_not_equal(text_id, reloaded_motion.property_manager(NS.schema.text).send(:properties).first.id)
    assert_equal(name_id, reloaded_motion.property_manager(NS.schema.name).send(:properties).first.id)
    assert_equal 'New description', reloaded_motion.description
    assert_equal 'New description', reloaded_motion.property_manager(NS.schema.text).value

    assert_no_difference('Property.count') do
      motion.update!(description: nil)
    end

    assert_nil reloaded_motion.description
    assert_nil reloaded_motion.property_manager(NS.schema.text).value

    assert_no_difference('Property.count') do
      motion.description = 'from method'
      motion.save
    end
    assert_equal 'from method', reloaded_motion.description
    assert_equal 'from method', reloaded_motion[:description]
    assert_equal 'from method', reloaded_motion.property_manager(NS.schema.text).value

    assert_no_difference('Property.count') do
      motion[:description] = 'from array'
      motion.save
    end
    assert_equal 'from array', reloaded_motion.description
    assert_equal 'from array', reloaded_motion.property_manager(NS.schema.text).value
  end

  test 'property array assignment' do
    assert_empty intervention.communication
    assert_difference('Property.count' => 2) do
      intervention.update!(communication: %i[open_communication communication_processed])
    end
    prop_id = intervention.property_manager(NS.rivm[:communication]).send(:properties).first.id
    assert_difference('Property.count' => 0) do
      intervention.update!(communication: %i[open_communication communication_processed])
    end
    assert_equal %w[communication_processed open_communication], reloaded_intervention.communication.sort
    assert_equal prop_id, intervention.property_manager(NS.rivm[:communication]).send(:properties).first.id

    assert_difference('Property.count' => -1) do
      intervention.update!(communication: %i[open_communication])
    end
    assert_not_equal prop_id, intervention.property_manager(NS.rivm[:communication]).send(:properties).first.id
    prop_id = intervention.property_manager(NS.rivm[:communication]).send(:properties).first.id
    assert_difference('Property.count' => 0) do
      intervention.update!(communication: %i[open_communication])
    end
    assert_equal prop_id, intervention.property_manager(NS.rivm[:communication]).send(:properties).first.id
    assert_equal %w[open_communication], reloaded_intervention.communication
  end

  test 'property array assignment with non array' do
    intervention
    assert_difference('Property.count' => 1) do
      intervention.update!(communication: :open_communication)
    end
    prop_id = intervention.property_manager(NS.rivm[:communication]).send(:properties).first.id
    assert_difference('Property.count' => 0) do
      intervention.update!(communication: %i[open_communication])
    end
    assert_equal prop_id, intervention.property_manager(NS.rivm[:communication]).send(:properties).first.id
    assert_equal %w[open_communication], reloaded_intervention.communication
  end

  test 'property has_one association' do
    [reply1, reply2].each do |reply|
      assert_equal parent_comment, reply.parent_comment
    end

    assert_equal [reply1, reply2], parent_comment.comments.order(:id)
  end

  test 'property has_one assignment by record' do
    comment
    parent_comment
    assert_difference('Property.count' => 1) do
      comment.parent_comment = parent_comment
    end
    assert_equal parent_comment, comment.parent_comment
    assert_difference('Property.count' => 0) do
      comment.save
    end
    assert_equal parent_comment, comment.reload.parent_comment
  end

  test 'property has_one assignment by id' do
    comment
    parent_comment
    assert_difference('Property.count' => 0) do
      comment.parent_comment_id = parent_comment.uuid
    end
    assert_equal parent_comment, comment.parent_comment
    assert_difference('Property.count' => 1) do
      comment.save
    end
    assert_equal parent_comment, comment.reload.parent_comment
    assert_equal parent_comment, Comment.find_by(uuid: comment.uuid).parent_comment
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
    assert_difference('Property.count' => 0) do
      measure.phase_ids = [term1.uuid, term2.uuid]
    end
    assert_difference('Property.count' => 2) do
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
    assert_equal [term2, term1], measure.phases.order(:id)

    assert_equal [term2, term1], measure.reload.phases.order(:id)
  end

  test 'property has_many query' do
    assert_equal Comment.where(parent_comment_id: parent_comment.uuid).count, 0
    assert_equal Comment.where(parent_comment: parent_comment).count, 0
    reply1
    assert_equal Comment.where(parent_comment_id: parent_comment.uuid).count, 1
    assert_equal Comment.where(parent_comment: parent_comment).count, 1
  end

  test 'properties remain when destroying other page' do
    assert_not_nil freetown.bio
    ActsAsTenant.with_tenant(second_page) do
      second_page.destroy
    end
    assert_not_nil freetown.reload.bio
  end

  test 'property destruction' do
    assert_not_nil freetown.bio
    Property.where(predicate: NS.schema.description.to_s).destroy_all
    assert_nil freetown.reload.bio
  end

  test 'linked edge destruction' do
    assert_equal parent_comment, reply1.parent_comment
    assert_difference('reply1.properties.count' => -1) do
      parent_comment.destroy
    end
    assert_nil reply1.reload.parent_comment
  end

  test 'property with timezone' do
    current_hour = Time.current.hour
    Time.use_zone('Hawaii') do
      timezone_hour = Time.current.hour
      assert_not_equal(current_hour, timezone_hour)
      vote_event = reloaded_vote_event
      assert_equal(timezone_hour, vote_event.starts_at.hour)
      cached_value = vote_event.cached_properties[NS.schema.startDate.to_s].first
      assert(cached_value.ends_with?('+00:00'))
      assert_includes(cached_value, "T#{current_hour.to_s.rjust(2, '0')}")
      raw_value = vote_event
                    .properties
                    .find_by(predicate: NS.schema.startDate)
                    .read_attribute_before_type_cast(:datetime)
      assert_equal(current_hour, raw_value.hour)
    end
    assert_equal(current_hour, reloaded_vote_event.starts_at.hour)
  end

  private

  def reloaded_intervention
    Edge.find_by(uuid: intervention.uuid)
  end

  def reloaded_motion
    Edge.find_by(uuid: motion.uuid)
  end

  def reloaded_vote_event
    reloaded_motion.default_vote_event
  end
end
