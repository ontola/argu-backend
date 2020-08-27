# frozen_string_literal: true

class AccessTokenSerializer < BaseSerializer
  attribute :email, predicate: NS::SCHEMA.email, datatype: NS::XSD[:string]
  attribute :password, predicate: NS::ONTOLA[:password], datatype: NS::XSD[:string]
  attribute :redirect_url, predicate: NS::ONTOLA[:redirectUrl], datatype: NS::XSD[:string]
end
