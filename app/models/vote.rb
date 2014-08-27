class Vote < ActiveRecord::Base
  belongs_to :voteable, polymorphic: true
  belongs_to :voter, polymorphic: true

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}
  Vote::OPTIONS = ["pro", "con", "neutral", "abstain"]

  def for? item
    self.for.to_s === item.to_s
  end

end
