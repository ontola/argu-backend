# frozen_string_literal: true

module AcceptTermsHelper
  def params_to_hidden_fields(params, namespace = nil)
    safe_join(
      params.map do |key, value|
        if value.is_a?(Hash)
          params_to_hidden_fields(value, namespace ? "#{namespace}[#{key}]" : key)
        else
          hidden_field_tag namespace ? "#{namespace}[#{key}]" : key, value
        end
      end
    )
  end
end
