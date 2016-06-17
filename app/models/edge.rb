
class Edge < ActiveRecord::Base
  belongs_to :owner,
             polymorphic: true
  belongs_to :parent
  belongs_to :user
  has_many :children,
           class_name: 'Edge',
           inverse_of: :parent,
           foreign_key: :parent_id
  has_many :follows,
           class_name: 'Follow',
           inverse_of: :followable,
           foreign_key: :followable_id,
           dependent: :destroy

  before_destroy :update_children
  before_save :set_user_id

  acts_as_followable
  has_ltree_hierarchy

  # For Rails 5 attributes
  # The user that has created the edge's owner.
  # attribute :user, User
  # The model the edge belongs to
  # attribute :owner_id, :integer
  # attribute :owner_type, :string
  # Refers to the parent edge
  # attribute :parent_id, :integer

  def set_user_id
    self.user_id = owner.publisher.id
  end

  def update_children
    children.each do |child|
      child.update(parent: parent)
    end
  end
end
