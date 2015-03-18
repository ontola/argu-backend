class Group < ActiveRecord::Base
  include ArguBase

  belongs_to :forum
  has_many :group_memberships
  has_many :members, through: :group_memberships, class_name: 'Profile'
  has_many :group_responses


  def display_name
    self.name
  end

  def self.ordered (coll=[], keys= [])
    grouped = coll.group_by { |g| g.group }
    (keys + grouped.keys).map { |g| {g => GroupResponse.ordered(grouped[g] || {}) } }.reduce(&:merge)
  end

end
