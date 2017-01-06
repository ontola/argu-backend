# frozen_string_literal: true
FactoryGirl.define do
  factory :linked_record do
    before :create do |record|
      record.edge = Edge.new(parent: record.source.edge, user_id: User::COMMUNITY_ID)
      record.page = record.source.page
    end
  end
end
