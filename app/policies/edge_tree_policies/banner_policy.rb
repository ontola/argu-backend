# frozen_string_literal: true

class BannerPolicy < EdgePolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  permit_attributes %i[display_name description audience published_at expires_at dismiss_button]

  def show?
    return if has_unpublished_ancestors? && !show_unpublished?

    true
  end
end
