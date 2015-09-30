FactoryGirl.define do

  factory :question_answer do
    association :question
    association :motion
  end
end
