# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :argument do
    content "some content"
    title "some title"
    pro false
    association :statement, factory: :statement
    #creator # Fix for paper_trail not functioning (correctly) in rspec
  end
end
