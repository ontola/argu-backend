FactoryGirl.define do
  factory :project do
    association :forum, strategy: :create
    association :creator, factory: :profile
    association :publisher, factory: [:user, :follows_reactions_directly]
    start_date Time.current
    sequence(:title) { |n| "title#{n}" }
    content 'content'

    after :create do |project|
      project.create_activity action: :create,
                              recipient: project.parent_model,
                              owner: project.creator,
                              forum: project.forum

      project.publisher.follow(project.edge)
    end

    factory :published_project do
      before :create do |project|
        pp = project.create_argu_publication(
          published_at: Time.current,
          creator: project.creator)
        pp.commit
      end
    end
  end
end
