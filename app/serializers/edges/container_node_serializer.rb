# frozen_string_literal: true

class ContainerNodeSerializer < EdgeSerializer
  has_one :parent, predicate: NS::SCHEMA[:isPartOf], &:parent

  attribute :bio, predicate: NS::SCHEMA[:description]
  attribute :bio_long, predicate: NS::SCHEMA[:text]
  attribute :language, predicate: NS::SCHEMA[:language], datatype: NS::XSD[:string]
  attribute :follows_count, predicate: NS::ARGU[:followsCount]
  attribute :hide_header, predicate: NS::ONTOLA[:hideHeader]

  enum :locale,
       type: NS::SCHEMA[:Thing],
       predicate: NS::ARGU[:locale],
       options: Hash[
         ISO3166::Country.codes
           .flat_map do |code|
           ISO3166::Country.new(code).languages_official.map do |language|
             [
               "#{language}-#{code}".to_sym,
               {
                 exact_match: NS::ARGU["locale-#{language}#{code}"],
                 label: -> { "#{ISO3166::Country.translations(I18n.locale)[code]} (#{language.upcase})" }
               }
             ]
           end
         end
       ]
end
