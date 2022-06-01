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
    assert_empty argu.allowed_external_sources
    assert_difference('Property.count' => 2) do
      argu.update!(allowed_external_sources: %i[first second])
    end
    prop_id = argu.property_manager(NS.ontola[:allowedExternalSources]).send(:properties).first.id
    assert_difference('Property.count' => 0) do
      argu.update!(allowed_external_sources: %i[first second])
    end
    assert_equal %w[first second], reloaded_argu.allowed_external_sources.sort
    assert_equal prop_id, argu.property_manager(NS.ontola[:allowedExternalSources]).send(:properties).first.id

    assert_difference('Property.count' => -1) do
      argu.update!(allowed_external_sources: %i[first])
    end
    assert_not_equal prop_id, argu.property_manager(NS.ontola[:allowedExternalSources]).send(:properties).first.id
    prop_id = argu.property_manager(NS.ontola[:allowedExternalSources]).send(:properties).first.id
    assert_difference('Property.count' => 0) do
      argu.update!(allowed_external_sources: %i[first])
    end
    assert_equal prop_id, argu.property_manager(NS.ontola[:allowedExternalSources]).send(:properties).first.id
    assert_equal %w[first], reloaded_argu.allowed_external_sources
  end

  test 'property array assignment with non array' do
    assert_difference('Property.count' => 1) do
      argu.update!(allowed_external_sources: :first)
    end
    prop_id = argu.property_manager(NS.ontola[:allowedExternalSources]).send(:properties).first.id
    assert_difference('Property.count' => 0) do
      argu.update!(allowed_external_sources: %i[first])
    end
    assert_equal prop_id, argu.property_manager(NS.ontola[:allowedExternalSources]).send(:properties).first.id
    assert_equal %w[first], reloaded_argu.allowed_external_sources
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

  def reloaded_argu
    Edge.find_by(uuid: argu.uuid)
  end

  def reloaded_motion
    Edge.find_by(uuid: motion.uuid)
  end

  def reloaded_vote_event
    reloaded_motion.default_vote_event
  end
end
