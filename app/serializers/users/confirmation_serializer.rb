# frozen_string_literal: true

module Users
  class ConfirmationSerializer < BaseSerializer
    attribute :email, predicate: NS::SCHEMA[:email], datatype: NS::XSD[:string]
    attribute :redirect_url, predicate: NS::ARGU[:redirectUrl]
  end
end
