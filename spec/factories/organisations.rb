# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organisations do
    name "MyString"
    website "MyString"
    public false
    listed false
    requestable false
    description "MyText"
    slogan "MyString"
    key_tags "MyString"
  end
end
