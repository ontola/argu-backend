# frozen_string_literal: true

class HomePlacementSerializer < PlacementSerializer
  class CountryOptions
    @options = {}
    extend CountrySelect::TagHelper

    def self.options
      Hash[
        country_options.map do |key, value|
          [value.upcase.to_sym, label: key, exact_match: NS.argu["Country/#{value}"]]
        end
      ]
    end
  end

  enum :country_code,
       predicate: NS.schema.addressCountry,
       type: NS.schema.Country,
       options: CountryOptions.options
end
