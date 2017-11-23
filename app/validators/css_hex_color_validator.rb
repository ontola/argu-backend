# frozen_string_literal: true

class CssHexColorValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value.nil? || value =~ /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/i
    object.errors[attribute] << (options[:message] || 'must be a valid CSS hex color code')
  end
end
