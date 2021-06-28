# frozen_string_literal: true

class PageSerializer < EdgeSerializer
  def self.manager?(object, opts)
    opts[:scope].user.managed_pages.include?(object)
  end

  attribute :name, predicate: NS.foaf[:name], datatype: NS.xsd.string do |object|
    profile = object.is_a?(Profile) ? object : object.profile
    profile&.name
  end
  attribute :url, predicate: NS.argu[:shortname], datatype: NS.xsd.string
  attribute :follows_count, predicate: NS.argu[:followsCount]
  attribute :accepted_terms, predicate: NS.argu[:acceptedTerms], datatype: NS.xsd.boolean, if: method(:manager?)
  attribute :last_accepted, predicate: NS.argu[:lastAccepted], if: method(:manager?)
  attribute :database_schema, predicate: NS.argu[:dbSchema], if: method(:service_scope?)

  has_one :primary_container_node, predicate: NS.foaf[:homepage], unless: method(:service_scope?)
  has_one :profile, predicate: NS.argu[:profile]

  with_collection :container_nodes, predicate: NS.argu[:forums]

  enum :locale,
       type: NS.schema.Thing,
       predicate: NS.argu[:locale],
       options: Hash[
         ISO3166::Country.codes.flat_map do |code|
           ISO3166::Country.new(code).languages_official.map do |language|
             [
               "#{language}-#{code}".to_sym,
               {
                 exact_match: NS.argu["locale-#{language}#{code}"],
                 label: -> { "#{ISO3166::Country.translations(I18n.locale)[code]} (#{language.upcase})" }
               }
             ]
           end
         end
       ]
end
