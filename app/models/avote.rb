class Avote < ActiveRecord::Base
  belongs_to :voteable, polymorphic: true
  belongs_to :voter, polymorphic: true

  enum for: [:pro, :con, :neutral]
end
