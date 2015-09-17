FactoryGirl.define do

  factory :question, traits: [:tenantable] do
    association :creator, factory: :profile

    title 'title'
    content 'content'

    trait :with_motions do
      after :create do |question|
        create_list :motion, 10,
                    questions: [question]
        create_list :motion, 10,
                    questions: [question],
                    is_trashed: true
      end
    end
  end
end
