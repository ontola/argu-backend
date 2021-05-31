# frozen_string_literal: true

module TranslatableProperties
  def translate_property(prop)
    return if prop.blank?

    use_translation = prop.match?(/^[a-z._]+$/)

    use_translation ? LinkedRails.translations(-> { I18n.t(prop, default: prop) }) : prop
  end
end
