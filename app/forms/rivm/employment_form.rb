# frozen_string_literal: true

class EmploymentForm < ApplicationForm
  field :organization_name
  field :job_title
  field :industry
  field :show_organization_name
  has_one :default_profile_photo
end
