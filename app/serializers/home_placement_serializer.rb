# frozen_string_literal: true

class HomePlacementSerializer < PlacementSerializer
  class CountryOptions
    @options = {}
    extend CountrySelect::TagHelper

    def self.options
      Hash[
        country_options.map do |key, value|
          [value.upcase.to_sym, label: key, exact_match: NS::ARGU["Country/#{value}"]]
        end
      ]
    end
  end

  enum :country_code,
       predicate: NS::SCHEMA[:addressCountry],
       type: NS::SCHEMA[:Country],
       options: CountryOptions.options
end
