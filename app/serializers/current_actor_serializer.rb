# frozen_string_literal: true
class CurrentActorSerializer < BaseSerializer
  attributes %i(actor_type finished_intro display_name shortname url)
  has_one :profile_photo do
    obj = object.actor&.default_profile_photo
    if obj
      link(:self) do
        {
          meta: {
            '@type': 'http://schema.org/image'
          }
        }
      end
      link(:related) do
        {
          href: obj.context_id,
          meta: {
            '@type': 'http://schema.org/ImageObject'
          }
        }
      end
    end
    obj
  end
end
