class Group < ActiveRecord::Base
  include ArguBase

  belongs_to :forum
  has_many :group_memberships
  has_many :members, through: :group_memberships, class_name: 'Profile'
  has_many :group_responses

  validates :name, length: {maximum: 75}


  def display_name
    self.name
  end

  def self.ordered (coll=[], keys= [])
    grouped = coll.group_by { |g| g.group }
    (keys + grouped.keys).map { |g| {g => GroupResponse.ordered_with_meta(grouped[g] || {}) } }.reduce(&:merge)
  end

  def self.ordered_with_meta (coll=[], keys= [], profile, obj)
    grouped = coll.group_by { |g| g.group }
    (keys + grouped.keys).map { |g| {g => GroupResponse.ordered_with_meta(grouped[g] || {}, profile, obj, g) } }.reduce(&:merge)
  end

  def include?(profile)
    self.members.include?(profile)
  end

end
