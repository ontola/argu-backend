# frozen_string_literal: true
class Vote < ApplicationRecord
  include Parentable, Loggable, PublicActivity::Model, Ldable

  belongs_to :creator, class_name: 'Profile', inverse_of: :votes
  belongs_to :publisher, class_name: 'User', foreign_key: 'publisher_id'
  has_many :activities, -> { order(:created_at) }, as: :trackable
  belongs_to :forum
  before_save :decrement_previous_counter_cache, unless: :new_record?
  before_save :set_explained_at, if: :explanation_changed?
  before_save :up_and_downvote_arguments

  attr_writer :argument_ids
  parentable :argument, :vote_event

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}
  filterable option: {key: 'votes.for', values: {yes: Vote.fors[:pro], other: Vote.fors[:neutral], no: Vote.fors[:con]}}
  counter_cache votes_pro: {for: Vote.fors[:pro]},
                votes_con: {for: Vote.fors[:con]},
                votes_neutral: {for: Vote.fors[:neutral]}

  validates :creator, :for, presence: true

  contextualize_as_type 'argu:Vote'
  contextualize_with_id { |v| Rails.application.routes.url_helpers.vote_url(v, protocol: :https) }
  contextualize :option, as: 'schema:option'

  # #########methods###########
  def argument_ids
    @argument_ids ||= upvoted_arguments.pluck(:id)
  end

  def upvoted_arguments
    @upvoted_arguments ||= Argument
                             .joins(:votes, :edge)
                             .where(votes: {creator: creator}, edges: {parent_id: parent_model&.edge&.parent_id})
  end

  def decrement_previous_counter_cache
    return unless for_changed? || explanation_changed?
    edge.decrement_counter_cache("votes_#{for_was}")
  end

  # Needed for ActivityListener#audit_data
  def display_name
    "#{self.for} vote for #{parent_model.display_name}"
  end

  def for?(item)
    self.for.to_s == item.to_s
  end

  def is_pro_con?
    true
  end

  def key
    self.for.to_sym
  end

  delegate :is_trashed?, to: :parent_model

  # #########Class methods###########
  def self.ordered(votes)
    grouped = votes.to_a.group_by(&:for)
    HashWithIndifferentAccess.new(
      pro: {collection: grouped['pro'] || []},
      neutral: {collection: grouped['neutral'] || []},
      con: {collection: grouped['con'] || []}
    )
  end

  private

  def set_explained_at
    self.explained_at = DateTime.current
  end

  def up_and_downvote_arguments
    (upvoted_arguments.pluck(:id) - argument_ids).each do |argument_id|
      Argument.find(argument_id).remove_upvote(publisher, creator)
    end
    (argument_ids - upvoted_arguments.pluck(:id)).each do |argument_id|
      Argument.find(argument_id).upvote(publisher, creator)
    end
  end
end
