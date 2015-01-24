class Vote < ActiveRecord::Base
  include ArguBase, PublicActivity::Model

  belongs_to :voteable, polymorphic: true
  belongs_to :voter, polymorphic: true
  belongs_to :forum

  after_validation :update_counter_cache

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}

  validates :voteable_id, :voteable_type, :voter_id, :forum_id, :voter_type, :for, presence: true

  ##########methods###########
  def for? item
    self.for.to_s === item.to_s
  end

  def update_counter_cache
    if self.for_was != self.for
      voteable.class.decrement_counter("votes_#{self.for_was}_count", voteable.id) if self.for_was
      voteable.class.increment_counter("votes_#{self.for}_count", voteable.id)
    end
  end

  ##########Class methods###########
  def self.ordered(votes)
    grouped = votes.to_a.group_by(&:for)
    HashWithIndifferentAccess.new(pro: {collection: grouped['pro'] || []}, neutral: {collection: grouped['neutral'] || []}, con: {collection: grouped['con'] || []})
  end

end
