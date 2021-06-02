# frozen_string_literal: true

FactoryBot.define do
  factory :offer do
    price { 100 }
    before(:create) do |record|
      record.product_id = create(:motion, record.parent).uuid
    end
  end
end
