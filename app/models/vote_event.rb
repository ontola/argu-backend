# frozen_string_literal: true

class VoteEvent < Edge # rubocop:disable Metrics/ClassLength
  DEFAULT_ID = 'default'

  enhance Actionable

  with_collection :votes, default_filters: [{'option' => 'no'}, {'option' => 'other'}, 'option' => 'yes']

  counter_cache true
  parentable :motion, :linked_record, touch: true
  property :starts_at, :datetime, NS::SCHEMA[:startDate]

  def con_count
    children_count(:votes_con)
  end

  def display_name
    'Argu voting'
  end

  def iri_opts
    super.merge(id: to_param, parent_iri: parent_iri_path)
  end

  def neutral_count
    children_count(:votes_neutral)
  end

  def pro_count
    children_count(:votes_pro)
  end

  def stats # rubocop:disable Metrics/AbcSize
    return @stats if @stats.present?
    totals = Vote
               .where(parent_id: id)
               .select('votes.for, count(*) as count')
               .group(:for)
               .to_a
    totals_confirmed = Vote
                         .joins(publisher: :email_addresses)
                         .where('email_addresses.confirmed_at IS NOT NULL')
                         .where(parent_id: id)
                         .select('votes.for, count(DISTINCT votes.id) as count')
                         .group(:for)
                         .to_a
    totals_facebook = Vote
                        .joins(publisher: :identities)
                        .where(identities: {provider: 'facebook'})
                        .where(parent_id: id)
                        .select('votes.for, count(DISTINCT votes.id) as count')
                        .group(:for)
                        .to_a
    @stats = %w[pro neutral con].map do |side|
      total = totals.find { |s| s.for == side }&.count || 0
      {
        confirmed: total.positive? ? (totals_confirmed.find { |s| s.for == side }&.count&.to_f || 0) / total : nil,
        facebook: total.positive? ? (totals_facebook.find { |s| s.for == side }&.count&.to_f || 0) / total : nil,
        side: side,
        total: total
      }
    end
  end

  def to_param
    fragment || 'default'
  end

  def total_vote_count
    children_count(:votes_pro).abs + children_count(:votes_con).abs + children_count(:votes_neutral).abs
  end

  def vote_collection_iri_opts
    if parent.is_a?(LinkedRecord)
      parent.iri_opts.merge(vote_event_id: VoteEvent::DEFAULT_ID)
    else
      iri_opts.slice(:vote_event_id, :motion_id, :linked_record_id)
    end
  end

  def voteable
    parent
  end

  def votes_pro_percentages
    {
      pro: votes_pro_percentage,
      neutral: votes_neutral_percentage,
      con: votes_con_percentage
    }
  end

  def votes_pro_percentage
    vote_percentage children_count(:votes_pro)
  end

  def votes_neutral_percentage
    vote_percentage children_count(:votes_neutral)
  end

  def votes_con_percentage
    vote_percentage children_count(:votes_con)
  end

  def vote_percentage(vote_count)
    if vote_count.zero?
      if total_vote_count.zero?
        33
      else
        0
      end
    else
      (vote_count.to_f / total_vote_count * 100).round.abs
    end
  end

  class << self
    def preview_includes
      [
        vote_collection: inc_shallow_collection
      ]
    end
  end
end
