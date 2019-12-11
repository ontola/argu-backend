# frozen_string_literal: true

FactoryBot.define do
  factory :employment do
    sequence(:organization_name) { |n| "fg organization #{n}end" }
    sequence(:job_title) { |n| "fg job title #{n}end" }
    industry :argiculutre
  end
end
