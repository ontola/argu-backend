FactoryGirl.define do
  trait :published do
    is_published true
    association :argu_publication, factory: :publication
  end

  trait :unpublished do
    is_published false
  end
end
