FactoryGirl.define do
  trait :tenantable do
    transient do
      tenant nil
    end
    before(:create) do |argument, evaluator|
      if evaluator.tenant.present?
        Apartment::Tenant.switch! evaluator.tenant
      end
    end
  end
end
