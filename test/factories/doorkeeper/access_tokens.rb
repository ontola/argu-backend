# frozen_string_literal: true

FactoryGirl.define do
  factory :access_token, class: Doorkeeper::AccessToken do
    association :application, factory: :application
    association :resource_owner_id, factory: :user

    trait :guest do
      scopes 'guest'
    end

    trait :user do
      scopes 'user'
    end

    trait :service do
      scopes 'service'
    end

    trait :export do
      scopes 'export'
    end
  end
end
