# frozen_string_literal: true

class IdentitySerializer < BaseSerializer
  attribute :password, predicate: NS::ARGU[:password], datatype: NS::ONTOLA['datatype/password'], if: :never
end
