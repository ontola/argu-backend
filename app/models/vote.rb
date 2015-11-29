class Vote < ActiveRecord::Base
  include ArguBase, PublicActivity::Model, CounterChainable

  belongs_to :voteable, polymorphic: true, inverse_of: :votes
  belongs_to :voter, polymorphic: true #class_name: 'Profile'
  has_many :activities, as: :trackable, dependent: :destroy
  belongs_to :forum

  after_save :update_counter_chain
  after_destroy :update_counter_chain

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}

  validates :voteable, :voter, :forum, :for, presence: true
  validates :for,
            unless: 'voteable.blank?',
            inclusion: {
              in: ->(arg) {
                arg.voteable.class::VOTE_OPTIONS.map(&:to_s)
              } }

  ##########methods###########
  def for?(item)
    self.for.to_s === item.to_s
  end

  delegate :is_trashed?, to: :voteable

  def update_counter_chain
    voteable.update_counter_chain
  end

  def voter_type
    'Profile'
  end

  ##########Class methods###########
  def self.ordered(votes)
    grouped = votes.to_a.group_by(&:for)
    HashWithIndifferentAccess.new(pro: {collection: grouped['pro'] || []}, neutral: {collection: grouped['neutral'] || []}, con: {collection: grouped['con'] || []})
  end

end
