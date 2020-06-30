# frozen_string_literal: true

class CategoryPolicy < EdgePolicy
  permit_attributes %i[display_name description]

  def show?
    return true if record.parent.is_a?(Page) || record.parent.nil?

    super
  end
end
