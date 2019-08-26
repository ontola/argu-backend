# frozen_string_literal: true

class ContainerNodeSerializer < EdgeSerializer
  attribute :bio, predicate: NS::SCHEMA[:description]
  attribute :bio_long, predicate: NS::SCHEMA[:text]
  attribute :language, predicate: NS::SCHEMA[:language], datatype: NS::XSD[:string]
  attribute :locale, predicate: NS::ARGU[:locale]
  attribute :follows_count, predicate: NS::ARGU[:followsCount]
  attribute :hide_header, predicate: NS::ARGU[:hideHeader]

  with_collection :grants, predicate: NS::ARGU[:grants]

  enum :locale,
       type: NS::SCHEMA[:Thing],
       options: Hash[
         ISO3166::Country.codes
           .flat_map do |code|
           ISO3166::Country.new(code).languages_official.map do |language|
             [
               "#{language}-#{code}".to_sym,
               {
                 iri: NS::ARGU["locale#{language}#{code}"],
                 label: -> { "#{ISO3166::Country.translations(I18n.locale)[code]} (#{language.upcase})" }
               }
             ]
           end
         end
       ]

  def hide_header
    !object.show_header
  end
end
