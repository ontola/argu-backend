# frozen_string_literal: true

class UpdatePage < EdgeableUpdateService
  include UUIDHelper

  def initialize(resource, attributes: {}, options: {})
    node_id = attributes[:primary_container_node_id]
    if node_id && !uuid?(node_id)
      attributes[:primary_container_node_id] = ContainerNode.find_via_shortname!(node_id).uuid
    end
    super
  end
end
