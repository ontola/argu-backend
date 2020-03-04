# frozen_string_literal: true

class EmploymentModeration < Employment
  enhance LinkedRails::Enhancements::Tableable

  with_columns default: [
    NS::SCHEMA.creator,
    NS::SCHEMA[:email],
    NS::SCHEMA.roleName,
    NS::ARGU[:organizationName],
    NS::ONTOLA[:confirmAction]
  ]

  def employee_email
    user.email
  end

  def iri_template_name
    :employment_moderations_iri
  end

  class << self
    def sti_name
      :Employment
    end

    def find_sti_class(_type_name)
      self
    end
  end
end
