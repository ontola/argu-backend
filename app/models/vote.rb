# frozen_string_literal: true
class Vote < ApplicationRecord
  include Parentable, Loggable, PublicActivity::Model, Ldable

  belongs_to :voter, class_name: 'Profile', inverse_of: :votes
  alias creator voter
  alias creator= voter=
  belongs_to :publisher, class_name: 'User', foreign_key: 'publisher_id'
  has_many :activities, -> { order(:created_at) }, as: :trackable
  belongs_to :forum
  before_save :decrement_previous_counter_cache, unless: :new_record?

  parentable :argument, :motion, :linked_record

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}
  counter_cache votes_pro: {for: Vote.fors[:pro]},
                votes_con: {for: Vote.fors[:con]},
                votes_neutral: {for: Vote.fors[:neutral]}

  validates :voter, :for, presence: true

  contextualize_as_type 'argu:Vote'
  contextualize_with_id { |v| Rails.application.routes.url_helpers.vote_url([v.parent_model, v], protocol: :https) }
  contextualize :for, as: 'schema:option'

  # #########methods###########
  def decrement_previous_counter_cache
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

  def voter_type
    'Profile'
  end
end
