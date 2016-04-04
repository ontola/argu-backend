FactoryGirl.define do
  factory :group do
    forum {
      passed_in?(:forum) ? forum : create(:forum)
    }
    sequence(:name) { |i| "fg_groups#{i}" }
    name_singular 'Group'
    visibility :hidden

    %i(hidden visible discussion).each do |vis|
      trait vis do
        visibility vis
      end
    end
  end
end
