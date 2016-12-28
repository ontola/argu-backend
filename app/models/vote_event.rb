# frozen_string_literal: true
class VoteEvent < ApplicationRecord
  include Parentable, Ldable
  belongs_to :creator, class_name: 'Profile', inverse_of: :projects
  belongs_to :forum, inverse_of: :projects
  belongs_to :group
  belongs_to :publisher, class_name: 'User'
  edge_tree_has_many :votes

  validate :ends_at_after_starts_at

  contextualize_as_type 'argu:VoteEvent'
  contextualize_with_id { |r| Rails.application.routes.url_helpers.vote_event_url(r, protocol: :https) }
  contextualize :starts_at, as: 'http://schema.org/startDate'
  contextualize :ends_at, as: 'http://schema.org/endDate'

  parentable :motion, :linked_record

  enum result: {pending: 0, pass: 1, fail: 2}

  delegate :is_trashed?, to: :parent_model

  def closed?
    starts_at.nil? || ends_at.present? && !DateTime.current.between?(starts_at, ends_at) || parent_model.try(:closed?)
  end

  def display_name
    group_id == -1 ? 'Argu voting' : "Voting by #{group.name}"
  end

  def ends_at_after_starts_at
    return unless starts_at.present? && ends_at.present? && ends_at < starts_at
    errors.add(:ends_at, "can't be before start date")
  end

  def total_vote_count
    children_count(:votes_pro).abs + children_count(:votes_con).abs + children_count(:votes_neutral).abs
  end

  def voteable
    parent_model
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
