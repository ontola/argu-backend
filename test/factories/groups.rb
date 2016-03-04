FactoryGirl.define do

  factory :group do
    association :forum, strategy: :build
    sequence(:name) { |i| "Fg_groups_#{i}" }
    name_singular 'Group'
    visibility :hidden

    %i(hidden visible discussion).each do |vis|
      trait vis do
        visibility vis
      end
    end

  end
end
