# frozen_string_literal: true

class SetupPolicy < RestrictivePolicy
  def permitted_attribute_names
    [:first_name, :middle_name, :last_name, :url, shortname_attributes: %i[shortname id]]
  end
end
