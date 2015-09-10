FactoryGirl.define do

  factory :motion do
    transient do
      tenant nil
    end

    association :creator, factory: :profile

    sequence(:title) { |n| "title#{n}" }
    content 'content'
    is_trashed false

    before(:create) do |argument, evaluator|
      if evaluator.tenant.present?
        Apartment::Tenant.switch! evaluator.tenant
      end
    end

  end
end
