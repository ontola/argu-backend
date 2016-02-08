FactoryGirl.define do
  trait :published do
    published_at Time.current
  end

  trait :unpublished do
    published_at nil
  end
end
