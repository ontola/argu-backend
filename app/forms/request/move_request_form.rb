# frozen_string_literal: true

module Request
  class MoveRequestForm < FormsBase
    field :move_to_edge_id, path: NS::ARGU[:moveTo], max_count: 1
  end
end