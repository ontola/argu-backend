# frozen_string_literal: true

class GuestUserSerializer < BaseSerializer
  attribute :display_name, predicate: NS.schema.name
  attribute :language, predicate: NS.schema.language do
    UserSerializer.enum_options(:language)[I18n.locale]&.iri
  end

  def self.self?(object, opts)
    object == opts[:scope]&.user
  end
end
