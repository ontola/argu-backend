FactoryGirl.define do
  factory :project do
    association :forum, strategy: :create
    association :creator, factory: :profile
    start_date Time.current
    sequence(:title) { |n| "title#{n}" }
    content 'content'

    factory :published_project do
      before :create do |project|
        pp = project.create_argu_publication(published_at: Time.current)
        pp.commit
      end
    end
  end
end
