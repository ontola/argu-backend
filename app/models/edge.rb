
class Edge < ActiveRecord::Base
  belongs_to :owner,
             inverse_of: :edge,
             polymorphic: true,
             required: true
  # Convert the polymorphic association Owner to a direct association with a Forum
  # This allows defining a counter_culture from Follow to Forum
  # @todo convert Forum.memberships_count to Edge.follows_count to remove this association
  belongs_to :forum,
             foreign_key: :owner_id,
             class_name: 'Forum'
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
  has_many :grants, dependent: :destroy
  has_many :groups, through: :grants
  has_many :group_memberships, through: :groups

  validates :parent, presence: true, unless: :root_object?

  before_destroy :update_children
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

  def set_user_id
    self.user_id = owner.publisher.id
  end

  def update_children
    children.each do |child|
      child.update(parent: parent)
    end
  end
end
