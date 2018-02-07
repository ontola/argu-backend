# frozen_string_literal: true

class EdgeableCollection < Collection
  def members
    super&.each { |m| m.is_a?(Edge) ? m.parent = parent&.edge : m.edge.parent = parent&.edge }
  end
end
