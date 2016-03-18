class Vote < ActiveRecord::Base
  include ArguBase, PublicActivity::Model

  belongs_to :voteable, polymorphic: true, inverse_of: :votes
  belongs_to :voter, polymorphic: true #class_name: 'Profile'
  has_many :activities, as: :trackable, dependent: :destroy
  belongs_to :forum

  after_save :update_parentable_counter
  after_destroy :update_parentable_counter

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}

  validates :voteable, :voter, :forum, :for, presence: true

  ##########methods###########
  def for?(item)
    self.for.to_s === item.to_s
  end

  delegate :is_trashed?, to: :voteable

  def update_parentable_counter
    self.voteable.update_vote_counters
  end

  ##########Class methods###########
  def self.ordered(votes)
    grouped = votes.to_a.group_by(&:for)
    HashWithIndifferentAccess.new(pro: {collection: grouped['pro'] || []}, neutral: {collection: grouped['neutral'] || []}, con: {collection: grouped['con'] || []})
  end

  def voter_type
    'Profile'
  end
end
