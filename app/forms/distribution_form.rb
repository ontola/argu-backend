# frozen_string_literal: true

class DistributionForm < ApplicationForm
  fields [
    :display_name,
    :description,
    :access_url,
    :download_url,
    {format: {sh_in: ->(_r) {format_options}}},
    {media_type: {sh_in: ->(_r) {media_type_options}}},
    {license: {sh_in: ->(_r) {license_options}}},
    :byte_size,
    :page,
    {language: {sh_in: ->(_r) {language_options}}},
    :conforms_to,
    :rights,
    {status: {sh_in: ->(_r) {status_options}}},
    {issued: {default_value: ->(_r) {Time.current}}},
    {modified: {default_value: ->(_r) {Time.current}}},
    :footer
  ]

  property_group :footer,
                 iri: NS::ONTOLA[:footerGroup],
                 properties: [
                   creator: actor_selector
                 ]

  def self.status_options
    form_options(
      'status',
      type: NS::SKOS[:Concept],
      options: {
        completed: {
          label: 'afgerond',
          iri: RDF::URI('http://purl.org/adms/status/Completed')
        },
        under_development: {
          label: 'in ontwikkeling',
          iri: RDF::URI('http://purl.org/adms/status/UnderDevelopment')
        },
        deprecated: {
          label: 'niet langer ondersteund',
          iri: RDF::URI('http://purl.org/adms/status/Deprecated')
        },
        withdrawn: {
          label: 'teruggetrokken',
          iri: RDF::URI('http://purl.org/adms/status/Withdrawn')
        }
      }
    )
  end

  def self.license_options
    form_options(
      'license',
      type: NS::SKOS[:Concept],
      options: {
        cc_0: {
          label: 'CC-0',
          iri: RDF::URI('http://creativecommons.org/publicdomain/zero/1.0/deed.nl')
        },
        cc_by: {
          label: 'CC-BY',
          iri: RDF::URI('http://creativecommons.org/licenses/by/4.0/deed.nl')
        },
        cc_by_sa: {
          label: 'CC-BY-SA',
          iri: RDF::URI('http://creativecommons.org/licenses/by-sa/4.0/deed.nl')
        },
        no_open_license: {
          label: 'Geen open licentie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/geslotenlicentie')
        },
        geo_license: {
          label: 'Geo Gedeeld licentie',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/geogedeeld')
        },
        unknown_license: {
          label: 'Licentie onbekend',
          iri: RDF::URI('http://standaarden.overheid.nl/owms/terms/licentieonbekend')
        },
        public_license: {
          label: 'Publiek Domein',
          iri: RDF::URI('http://creativecommons.org/publicdomain/mark/1.0/deed.nl')
        }
      }
    )
  end

  def self.media_type_options
    form_options(
      'media_type',
      DistributionSerializer.default_enum_opts('media_type', Mime::SET.map(&:to_s))
    )
  end

  def self.format_options
    form_options(
      'format',
      DistributionSerializer.default_enum_opts('media_type', Mime::SET.map(&:to_s))
    )
  end

  def self.language_options
    form_options(
      'language',
      type: NS::SKOS[:Concept],
      options: {
        annual: {
          label: 'Nederlands',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/language/NLD')
        },
        annual_2: {
          label: 'Engels',
          iri: RDF::URI('http://publications.europa.eu/resource/authority/language/ENG')
        }
      }
    )
  end
end
