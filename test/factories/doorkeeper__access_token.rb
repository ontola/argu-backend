# frozen_string_literal: true

FactoryGirl.define do
  factory :doorkeeper__access_token, class: Doorkeeper::AccessToken do
    application { Doorkeeper::Application.find(0) }

    factory :guest_token do
      scopes 'guest'
    end

    factory :user_token do
      scopes 'user'
    end

    factory :service_token do
      resource_owner_id 0
      scopes 'service'
    end
  end
end
