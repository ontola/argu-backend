FactoryGirl.define do

  factory :question, traits: [:tenantable] do
    association :creator, factory: :profile

    title 'title'
    content 'content'
  end
end
