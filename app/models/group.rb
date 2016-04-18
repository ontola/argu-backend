class Group < ApplicationRecord
  include Parentable

  has_many :grants, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, class_name: 'Profile'
  has_many :group_responses, dependent: :destroy
  belongs_to :page, required: true, inverse_of: :groups
  belongs_to :forum
  has_many :decisions

  validates :name, length: {maximum: 75}
  validates :visibility, presence: true

  delegate :publisher, to: :page

  enum visibility: {hidden: 0, visible: 1, discussion: 2}
  parentable :page

  def as_json(options)
    super(options.merge(except: [:max_responses_per_member, :created_at, :updated_at]))
  end

  def display_name
    name
  end

  def include?(profile)
    members.include?(profile)
  end

  def self.ordered_with_meta (coll = [], keys = [], profile, obj)
    grouped = coll.group_by(&:group)
    (keys + grouped.keys)
      .map { |g| {g => GroupResponse.ordered_with_meta(grouped[g] || {}, profile, obj, g)} }
      .reduce(&:merge)
  end

  def responses_left(group_respondable, profile)
    if include?(profile)
      if max_responses_per_member == -1
        Float::INFINITY
      else
        max_responses_per_member - group_respondable.responses_from(profile, self)
      end
    else
      -1
    end
  end

  def responses_for(group_respondable, profile)
    group_respondable.group_responses.where(group: self, creator: profile)
  end
end
