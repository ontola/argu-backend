# frozen_string_literal: true
FactoryGirl.define do
  factory :place do
    address do
      {
        'suburb' => 'Utrecht',
        'city' => 'Utrecht',
        'county' => 'Bestuur Regio Utrecht',
        'state' => 'Utrecht',
        'postcode' => '3583GP',
        'country' => 'Nederland',
        'country_code' => 'nl'
      }
    end
  end
end
