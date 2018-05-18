# frozen_string_literal: true

class VoteEvent < Edge
  DEFAULT_ID = 'default'

  has_many_through_edge :votes, where: {primary: true}

  with_collection :votes, pagination: true

  parentable :motion, :linked_record

  property :starts_at, :datetime, NS::SCHEMA[:startDate]

  delegate :is_trashed?, to: :parent_model

  def con_count
    children_count(:votes_con)
  end

  def display_name
    'Argu voting'
  end

  def iri_opts
    super.merge(id: to_param, parent_iri: parent_iri(only_path: true))
  end

  def neutral_count
    children_count(:votes_neutral)
  end

  def pro_count
    children_count(:votes_pro)
  end

  def stats
    return @stats if @stats.present?
    totals = Vote
               .joins(:edge)
               .where(edges: {parent_id: edge.id})
               .select('votes.for, count(*) as count')
               .group(:for)
               .to_a
    totals_confirmed = Vote
                         .joins(:edge, publisher: :email_addresses)
                         .where('email_addresses.confirmed_at IS NOT NULL')
                         .where(edges: {parent_id: edge.id})
                         .select('votes.for, count(DISTINCT votes.id) as count')
                         .group(:for)
                         .to_a
    totals_facebook = Vote
                        .joins(:edge, publisher: :identities)
                        .where(identities: {provider: 'facebook'})
                        .where(edges: {parent_id: edge.id})
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
    edge.fragment || 'default'
  end

  def total_vote_count
    children_count(:votes_pro).abs + children_count(:votes_con).abs + children_count(:votes_neutral).abs
  end

  def vote_collection_iri_opts
    if parent_model.is_a?(LinkedRecord)
      parent_model.iri_opts.merge(vote_event_id: VoteEvent::DEFAULT_ID)
    else
      iri_opts.slice(:vote_event_id, :motion_id, :linked_record_id)
    end
  end

  def voteable
    parent_model
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
end
