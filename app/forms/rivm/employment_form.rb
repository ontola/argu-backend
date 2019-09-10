# frozen_string_literal: true

class EmploymentForm < ApplicationForm
  fields %i[
    organization_name
    job_title
    industry
    default_profile_photo
  ]
end
