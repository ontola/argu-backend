# frozen_string_literal: true

class ForumSerializer < EdgeSerializer
  attribute :bio, predicate: NS::SCHEMA[:description]
  attribute :bio_long, predicate: NS::SCHEMA[:text]
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string]
  attribute :language, predicate: NS::SCHEMA[:language], datatype: NS::XSD[:string]
  attribute :follows_count, predicate: NS::ARGU[:followsCount]
end
