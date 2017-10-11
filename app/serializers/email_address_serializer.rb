# frozen_string_literal: true

class EmailAddressSerializer < BaseSerializer
  attributes :email, :primary, :confirmed_at

  has_one :user do
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

  def id
    ld_id
  end
end
