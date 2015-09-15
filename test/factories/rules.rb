FactoryGirl.define do

  factory :rule, traits: [:tenantable] do
    model_type nil
    model_id nil
    permit false
    role 'member'
    action 'show?'
    context_type 'Forum'

    before :create do |rule, evaluator|
      rule.context_id = Forum.find_via_shortname(Apartment::Tenant.current).id
    end
  end
end
