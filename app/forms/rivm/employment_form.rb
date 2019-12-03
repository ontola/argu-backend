# frozen_string_literal: true

class EmploymentForm < ApplicationForm
  fields %i[
    organization_name
    job_title
    industry
    show_organization_name
    default_profile_photo
  ]
end
