# frozen_string_literal: true

class EmailAddressSerializer < BaseSerializer
  attribute :email, predicate: RDF::SCHEMA[:email]
  attribute :primary
  attribute :confirmed_at

  has_one :user, predicate: RDF::ARGU[:user] do
    obj = object.user
    link(:self) do
      {
        meta: {
          '@type': 'schema:creator'
        }
      }
    end
    link(:related) do
      {
        href: obj.context_id,
        meta: {
          '@type': obj.context_type
        }
      }
    end
    obj
  end
end
