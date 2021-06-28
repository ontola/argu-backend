# frozen_string_literal: true

module Users
  class ConfirmationSerializer < LinkedRails::Auth::ConfirmationSerializer
    attribute :email, predicate: NS.schema.email, datatype: NS.xsd.string do |object|
      object.email&.email
    end
  end
end
