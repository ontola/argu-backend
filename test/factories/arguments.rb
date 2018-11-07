# frozen_string_literal: true

FactoryBot.define do
  factory :argument do
    pro true
    sequence(:title) { |i| "fg argument title #{i}end" }
    sequence(:content) { |i| "fg argument content #{i}end" }

    factory :pro_argument do
      owner_type 'ProArgument'
    end

    factory :con_argument do
      owner_type 'ConArgument'
      pro false
    end
  end
end
