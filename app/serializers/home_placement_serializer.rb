# frozen_string_literal: true

class HomePlacementSerializer < PlacementSerializer
  class CountryOptions
    @options = {}
    extend CountrySelect::TagHelper

    def self.options
      Hash[country_options.map { |key, value| [value.upcase.to_sym, label: key, iri: NS::ARGU["Country/#{value}"]] }]
    end
  end

  enum :country_code,
       type: NS::SCHEMA[:Country],
       options: CountryOptions.options
end
