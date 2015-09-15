class Vote < ActiveRecord::Base
  include ArguBase, PublicActivity::Model

  belongs_to :voteable, polymorphic: true, inverse_of: :votes
  belongs_to :voter, polymorphic: true #class_name: 'Profile'
  has_many :activities, as: :trackable, dependent: :destroy

  after_save :update_counter_cache
  after_destroy :decrement_counter_cache

  enum for: {con: 0, pro: 1, neutral: 2, abstain: 3}

  validates :voteable_id, :voteable_type, :voter_id, :voter_type, :for, presence: true

  def self.cascaded_move_sql(ids, old_tenant, new_tenant)
    activities_ids = Activity
                         .where(trackable_type: self.class.name,
                                trackable_id: ids)
                         .pluck(:id)

    sql = ''
    sql << self.migration_base_sql(self, new_tenant, old_tenant) +
        "where voteable_id IS NOT NULL AND id IN (#{ids.join(',')}); "
    sql << Activity.cascaded_move_sql(activities_ids, old_tenant, new_tenant) if activities_ids.present?
  end

  def decrement_counter_cache
    voteable.class.decrement_counter(
        voteable.class.respond_to?("votes_#{self.for}_count") ? "votes_#{self.for}_count" : 'votes_pro_count',
        voteable.id
    )
  end

  def for?(item)
    self.for.to_s === item.to_s
  end

  def self.ordered(votes)
    grouped = votes.to_a.group_by(&:for)
    HashWithIndifferentAccess.new(pro: {collection: grouped['pro'] || []},
                                  neutral: {collection: grouped['neutral'] || []},
                                  con: {collection: grouped['con'] || []})
  end

  def update_counter_cache
    if self.for_was != self.for
      voteable.class.decrement_counter("votes_#{self.for_was}_count", voteable.id) if self.for_was
      voteable.class.increment_counter("votes_#{self.for}_count", voteable.id)
    end
  end

  def voter_type
    'Profile'
  end

end
