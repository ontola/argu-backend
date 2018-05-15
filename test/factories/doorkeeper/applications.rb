# frozen_string_literal: true

FactoryGirl.define do
  factory :application, class: Doorkeeper::Application do
    sequence(:name) { |i| "app_name_#{i}" }
    redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
    association :owner, factory: :user
  end
end
