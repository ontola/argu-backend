
class Edge < ActiveRecord::Base
  belongs_to :owner,
             polymorphic: true
  belongs_to :parent
  belongs_to :user
  has_many :children,
           class_name: 'Edge',
           inverse_of: :parent,
           foreign_key: :parent_id,
           dependent: :destroy
  has_many :follows,
           class_name: 'Follow',
           inverse_of: :followable,
           foreign_key: :followable_id,
           dependent: :destroy

  before_save :set_user_id

  acts_as_followable
  has_ltree_hierarchy

  # For Rails 5 attributes
  # The user that has created the edge's owner.
  # attribute :user, User
  # The model the edge belongs to
  # attribute :owner, :
  # Refers to the parent edge
  # attribute :parent_id, :integer
  # The identifier of the owner
  # attribute :fragment, :string
  # The identifier of the parent owner
  # attribute :parent_fragment, :string

  def set_user_id
    self.user_id = owner.publisher.id
  end
end
