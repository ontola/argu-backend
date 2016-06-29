# frozen_string_literal: true
class CreateMembership < ContentCreateService
  include Wisper::Publisher

  def initialize(parent, attributes: {}, options: {})
    super
    assign_forum_from_edge_tree
  end

  def resource_klass
    Membership
  end

  private

  def object_attributes=(obj)
  end
end
