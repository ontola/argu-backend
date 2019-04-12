# frozen_string_literal: true

class ContainerNodeSerializer < EdgeSerializer
  attribute :bio, predicate: NS::SCHEMA[:description]
  attribute :bio_long, predicate: NS::SCHEMA[:text]
  attribute :url, predicate: NS::ARGU[:shortname], datatype: NS::XSD[:string]
  attribute :language, predicate: NS::SCHEMA[:language], datatype: NS::XSD[:string]
  attribute :locale, predicate: NS::ARGU[:locale]
  attribute :follows_count, predicate: NS::ARGU[:followsCount]
  attribute :public_grant, predicate: NS::ARGU[:publicGrant]

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

  enum :public_grant,
       type: GrantSet.iri,
       options: Hash[
         [:none].concat(GrantSet::SELECTABLE_TITLES).map do |title|
           [title.to_sym, {iri: NS::ARGU["grantSet#{title}"], label: -> { I18n.t("roles.types.#{title}").capitalize }}]
         end
       ]
end
