FactoryGirl.define do
  factory :publication do
    association :creator, factory: :profile
    published_at DateTime.current
    channel 'argu'

    after(:build) do |publication|
      publication.class.skip_callback(:save, :after, :re_schedule_or_destroy)
    end

    factory :scheduled_publication do
      after(:create) do |publication|
        publication.send(:re_schedule_or_destroy)
      end
    end
  end
end
