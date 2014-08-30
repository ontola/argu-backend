class Vote < ActiveRecord::Base
  belongs_to :voteable, polymorphic: true, autosave: true
  belongs_to :voter, polymorphic: true

  after_validation :update_counter_cache

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}

  def for? item
    self.for.to_s === item.to_s
  end

  def update_counter_cache
    if self.for_was != self.for
      self.voteable.decrement("votes_#{self.for_was}_count") if self.for_was && self.for_was != 'abstain'
      self.voteable.increment("votes_#{self.for}_count") unless self.for == 'abstain'
    end
  end

end
