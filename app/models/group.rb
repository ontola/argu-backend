class Group < ActiveRecord::Base
  include ArguBase

  belongs_to :forum
  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, class_name: 'Profile'
  has_many :group_responses

  validates :name, length: {maximum: 75}

  def as_json(options)
    super(options.merge(except: [:max_responses_per_member, :created_at, :updated_at, :forum_id]))
  end

  def display_name
    self.name
  end

  def include?(profile)
    self.members.include?(profile)
  end

  def self.ordered (coll=[], keys= [])
    grouped = coll.group_by { |g| g.group }
    (keys + grouped.keys).map { |g| {g => GroupResponse.ordered_with_meta(grouped[g] || {}) } }.reduce(&:merge)
  end

  def self.ordered_with_meta (coll=[], keys= [], profile, obj)
    grouped = coll.group_by { |g| g.group }
    (keys + grouped.keys).map { |g| {g => GroupResponse.ordered_with_meta(grouped[g] || {}, profile, obj, g) } }.reduce(&:merge)
  end

  def responses_left(group_respondable, profile)
    if include?(profile)
      max_responses_per_member == -1 ? Float::INFINITY : max_responses_per_member - group_respondable.responses_from(profile)
      if max_responses_per_member == -1
        Float::INFINITY
      else
        max_responses_per_member - group_respondable.responses_from(profile)
      end
    else
      0
    end
  end

  def responses_for(group_respondable, profile)
    group_respondable.group_responses.where(group: self, profile: profile)
  end
end
