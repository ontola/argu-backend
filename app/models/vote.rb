class Vote < ActiveRecord::Base
  belongs_to :voteable, polymorphic: true, autosave: true
  belongs_to :voter, polymorphic: true

  after_validation :update_counter_cache

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}

  validates :voteable_id, :voteable_type, :voter_id, :voter_type, :for, presence: true

  ##########methods###########
  def for? item
    self.for.to_s === item.to_s
  end

  def update_counter_cache
    if self.for_was != self.for
      self.voteable.decrement("votes_#{self.for_was}_count") if self.for_was
      self.voteable.increment("votes_#{self.for}_count")
    end
  end

  ##########Class methods###########
  def self.ordered(votes)
    grouped = votes.group_by(&:for)
    HashWithIndifferentAccess.new(pro: {collection: grouped['pro']}, neutral: {collection: grouped['neutral']}, con: {collection: grouped['con']})
  end

end
