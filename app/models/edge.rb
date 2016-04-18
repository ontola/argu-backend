
class Edge < ActiveRecord::Base
  belongs_to :owner,
             inverse_of: :edge,
             polymorphic: true,
             required: true
  belongs_to :parent,
             class_name: 'Edge',
             inverse_of: :children
  belongs_to :user,
             required: true
  has_many :children,
           class_name: 'Edge',
           inverse_of: :parent,
           foreign_key: :parent_id
  has_many :follows,
           class_name: 'Follow',
           inverse_of: :followable,
           foreign_key: :followable_id,
           dependent: :destroy
  has_many :groups, dependent: :destroy
  has_one :members_group, -> { where(shortname: 'members') }, class_name: 'Group'
  has_one :managers_group, -> { where(shortname: 'managers') }, class_name: 'Group'

  validates :parent, presence: true, unless: :root_object?

  before_destroy :update_children
  before_create :build_default_groups
  before_save :set_user_id

  acts_as_followable
  has_ltree_hierarchy

  delegate :display_name, :root_object?, to: :owner

  # For Rails 5 attributes
  # The user that has created the edge's owner.
  # attribute :user, User
  # The model the edge belongs to
  # attribute :owner_id, :integer
  # attribute :owner_type, :string
  # Refers to the parent edge
  # attribute :parent_id, :integer

  # Only returns a value when the model has been saved
  def polymorphic_tuple
    [owner_type, owner_id]
  end

  def build_default_groups
    return unless %w(Forum Page).include?(owner_type)
    groups << Group.new(name: 'Members', shortname: 'members', name_singular: 'Member', deletable: false)
    groups << Group.new(name: 'Managers', shortname: 'managers', name_singular: 'Manager', deletable: false)
  end

  def set_user_id
    self.user_id = owner.publisher.id
  end

  def update_children
    children.each do |child|
      child.update(parent: parent)
    end
  end
end
