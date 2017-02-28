# frozen_string_literal: true
namespace :votes do
  desc 'Publish votes'
  task publish: :environment do
    Vote.where(voteable_type: 'Motion').find_each do |vote|
      DataEvent.new(vote).publish
    end
  end
end
