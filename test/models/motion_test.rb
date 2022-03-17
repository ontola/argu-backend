# frozen_string_literal: true

require 'test_helper'

class MotionTest < ActiveSupport::TestCase
  define_freetown
  subject { create(:motion, :with_arguments, parent: freetown) }
  let(:question) { create(:question, :with_motions, parent: freetown) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'active_arguments_con should not include trashed motions' do
    trashed_args = subject.arguments.trashed.pluck(:id)
    assert trashed_args.present?,
           'No trashed arguments exist, test is useless'
    assert_not((subject.active_con_arguments.map(&:id) & trashed_args).present?)
  end

  test 'active_arguments_pro should not include trashed motions' do
    trashed_args = subject.arguments.trashed.pluck(:id)
    assert trashed_args.present?,
           'No trashed arguments exist, test is useless'
    assert_not((subject.active_pro_arguments.map(&:id) & trashed_args).present?)
  end

  test 'convert to question' do
    ActsAsTenant.with_tenant(subject.root) do
      result = subject.convert_to(Question)
      assert result[:new].is_a?(Question)
      assert result[:old].is_a?(Motion)
      assert_equal result[:new].display_name, result[:old].display_name
    end
  end

  test 'raise when converting to non-convertible class' do
    subject.convert_to(Argument)
    assert_not true
  rescue ArgumentError
    assert true
  end

  test 'order by vote count' do
    assert_equal(
      question.motion_collection.association_base.order_values.map(&:to_sql), [
        '"edges"."pinned_at" ASC',
        "#{votes_pro_sorting} DESC",
        '"edges"."id" ASC'
      ]
    )

    question.update(default_motion_sorting: :popular_asc)
    assert_equal(
      question.motion_collection.association_base.order_values.map(&:to_sql), [
        '"edges"."pinned_at" ASC',
        "#{votes_pro_sorting} ASC",
        '"edges"."id" ASC'
      ]
    )

    question.update(default_motion_sorting: :updated_at)
    assert_equal(
      question.motion_collection.association_base.order_values.map(&:to_sql), [
        '"edges"."pinned_at" ASC',
        '"edges"."last_activity_at" DESC',
        '"edges"."id" ASC'
      ]
    )
  end

  private

  def votes_pro_sorting
    @pro_vote ||= Vocabulary.vote_options.active_terms.find_by(exact_match: NS.argu[:yes])

    "COALESCE(CAST(\"default_vote_events_edges\".\"children_counts\" -> '#{@pro_vote.uuid}' AS INT), 0)"
  end
end
