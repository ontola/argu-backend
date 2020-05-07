# frozen_string_literal: true

class BannerPolicy < EdgePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat(%i[display_name description audience published_at expires_at dismiss_button])
    attributes
  end

  def show?
    return if has_unpublished_ancestors? && !show_unpublished?

    true
  end
end
