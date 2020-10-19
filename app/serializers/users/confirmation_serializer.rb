# frozen_string_literal: true

module Users
  class ConfirmationSerializer < LinkedRails::Auth::ConfirmationSerializer
    attribute :email, predicate: RDF::Vocab::SCHEMA.email, datatype: RDF::XSD[:string] do |object|
      object.email&.email
    end
  end
end
