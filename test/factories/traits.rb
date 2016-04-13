FactoryGirl.define do
  trait :published do
    is_published true
    argu_publication factory: :publication, strategy: :build
  end

  trait :scheduled do
    is_published false
    argu_publication factory: :publication, strategy: :build
  end

  trait :unpublished do
    is_published false
  end
end
