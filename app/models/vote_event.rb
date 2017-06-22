# frozen_string_literal: true
class VoteEvent < ApplicationRecord
  include Parentable, Ldable
  belongs_to :creator, class_name: 'Profile', inverse_of: :vote_events
  belongs_to :forum
  belongs_to :group
  belongs_to :publisher, class_name: 'User', required: true
  edge_tree_has_many :votes

  with_collection :votes, pagination: true

  contextualize_as_type 'argu:VoteEvent'
  contextualize_with_id { |r| Rails.application.routes.url_helpers.vote_event_url(r, protocol: :https) }
  contextualize :starts_at, as: 'http://schema.org/startDate'
  contextualize :ends_at, as: 'http://schema.org/endDate'

  parentable :motion, :linked_record

  enum result: {pending: 0, pass: 1, fail: 2}

  delegate :is_trashed?, to: :parent_model

  def display_name
    group_id == -1 ? 'Argu voting' : "Voting by #{group.name}"
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
                        .joins(:edge, publisher: :emails)
                        .where('emails.confirmed_at IS NOT NULL')
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
    @stats = %w(pro neutral con).map do |side|
      total = totals.find { |s| s.for == side }&.count || 0
      {
        confirmed: total.positive? ? (totals_confirmed.find { |s| s.for == side }&.count&.to_f || 0) / total : nil,
        facebook: total.positive? ? (totals_facebook.find { |s| s.for == side }&.count&.to_f || 0) / total : nil,
        side: side,
        total: total
      }
    end
  end

  def total_vote_count
    children_count(:votes_pro).abs + children_count(:votes_con).abs + children_count(:votes_neutral).abs
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
