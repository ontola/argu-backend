class Avote < ActiveRecord::Base
  belongs_to :voteable, polymorphic: true
  belongs_to :voter, polymorphic: true

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}
  Avote::OPTIONS = ["pro", "con", "neutral", "abstain"]

end
