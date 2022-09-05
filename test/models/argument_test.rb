# frozen_string_literal: true

require 'test_helper'

class ArgumentTest < ActiveSupport::TestCase
  define_freetown
  let(:motion) { create(:motion, parent: freetown) }
  subject { create(:pro_argument, parent: motion) }

  def test_valid
    assert subject.valid?, subject.errors.to_a.join(',').to_s
  end

  test 'order by vote count' do
    assert_equal(
      sorting_sql, [
        "#{votes_pro_sorting} DESC",
        '"edges"."id" ASC'
      ]
    )
  end

  private

  def sorting_sql
    ActsAsTenant.with_tenant(argu) do
      motion.pro_argument_collection.association_base.order_values.map(&:to_sql)
    end
  end

  def votes_pro_sorting
    @pro_vote ||= Vocabulary.upvote_options(argu.root_id).active_terms.find_by(exact_match: NS.argu[:yes])

    "COALESCE(CAST(\"edges\".\"children_counts\" -> '#{@pro_vote.uuid}' AS INT), 0)"
  end
end
