# frozen_string_literal: true

FactoryBot.define do
  factory :vote do
    add_attribute(:option) { :yes }
  end
end
