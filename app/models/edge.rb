
class Edge < Ltree::Models::Edge
  belongs_to :user
  before_save :set_user_id

  acts_as_followable

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

  def ltree_scope
    self.class
  end
end
