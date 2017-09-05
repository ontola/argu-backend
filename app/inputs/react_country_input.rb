# frozen_string_literal: true

class ReactCountryInput < ReactSelectInput
  include CountrySelect::TagHelper

  def to_html
    unless builder.respond_to?(:country_select)
      raise 'To use the :country input, please install a country_select plugin'\
        ', like this one: https://github.com/stefanpenner/country_select'
    end
    super
  end

  def react_options
    country_options.map { |k| {label: k[0], value: k[1]} }
  end

  def priority_countries
    options[:priority_countries] || builder.priority_countries
  end
end
