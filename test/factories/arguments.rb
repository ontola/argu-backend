# frozen_string_literal: true

FactoryGirl.define do
  factory :argument do
    pro true
    sequence(:title) { |i| "fg argument title #{i}end" }
    sequence(:content) { |i| "fg argument content #{i}end" }

    factory :pro_argument do
      type 'ProArgument'
    end

    factory :con_argument do
      type 'ConArgument'
    end
  end
end
