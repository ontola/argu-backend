FactoryGirl.define do
  factory :publication do
    association :creator, factory: :profile
    published_at DateTime.current
    channel 'argu'

    factory :scheduled_publication do
      after(:create) do |publication|
        publication.send(:re_schedule_or_destroy)
      end
    end
  end
end
