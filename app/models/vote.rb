# frozen_string_literal: true
class Vote < ApplicationRecord
  include Parentable, Loggable, PublicActivity::Model

  belongs_to :voteable, polymorphic: true, inverse_of: :votes
  belongs_to :voter, class_name: 'Profile', inverse_of: :votes
  alias creator voter
  alias creator= voter=
  belongs_to :publisher, class_name: 'User', foreign_key: 'publisher_id'
  has_many :activities, -> { order(:created_at) }, as: :trackable
  belongs_to :forum

  counter_cache true
  parentable :voteable

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}

  validates :voteable, :voter, :forum, :for, presence: true

  def counter_cache_name
    [class_name, key.to_s].join('_')
  end

  # #########methods###########
  # Needed for ActivityListener#audit_data
  def display_name
    "#{self.for} vote for #{voteable.display_name}"
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

  delegate :is_trashed?, to: :voteable

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
