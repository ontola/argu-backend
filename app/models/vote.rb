class Vote < ActiveRecord::Base
  belongs_to :voteable, polymorphic: true, autosave: true
  belongs_to :voter, polymorphic: true

  after_validation :update_counter_cache

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}


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
  def self.ordered (votes)
    HashWithIndifferentAccess.new(pro: [], neutral: [], con: []).merge votes.group_by { |a| a.for }
  end

end
