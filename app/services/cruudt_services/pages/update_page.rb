# frozen_string_literal: true

class UpdatePage < EdgeableUpdateService
  include UUIDHelper

  def initialize(resource, attributes: {}, options: {})
    node_id = attributes[:primary_container_node_id]
    attributes[:primary_container_node_id] = Forum.find_via_shortname!(node_id).uuid if node_id && !uuid?(node_id)
    super
  end
end
