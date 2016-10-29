# frozen_string_literal: true
class UserSerializer < BaseSerializer
  attributes :display_name, :about
  has_one :profile_photo do
    obj = object.profile.default_profile_photo
    link(:related) do
      {
        href: nil,
        meta: {
          '@type': 'http://schema.org/image',
          attributes: {
            '@id': obj.class.try(:context_id_factory)&.call(obj)
          }
        }
      }
    end
    obj
  end

  def about
    object.profile.about
  end
end
