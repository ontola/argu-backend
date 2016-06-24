FactoryGirl.define do
  factory :group do
    sequence(:name) { |i| "fg_groups#{i}end" }
    name_singular 'Group'
    visibility :hidden

    %i(hidden visible discussion).each do |vis|
      trait vis do
        visibility vis
      end
    end
  end
end
