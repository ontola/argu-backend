# frozen_string_literal: true

FactoryBot.define do
  factory :vote do
    add_attribute(:option) { NS.argu[:yes] }
  end
end
