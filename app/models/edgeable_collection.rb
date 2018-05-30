# frozen_string_literal: true

class EdgeableCollection < Collection
  def members
    super&.each { |m| m.parent = parent }
  end
end
