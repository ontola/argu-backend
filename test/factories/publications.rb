FactoryGirl.define do
  factory :publication do
    published_at DateTime.current
    channel 'argu'
  end
end
