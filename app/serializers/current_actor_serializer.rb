# frozen_string_literal: true

class CurrentActorSerializer < BaseSerializer
  attribute :actor_type, predicate: RDF::ARGU[:actorType], key: :body
  attribute :display_name, predicate: RDF::SCHEMA[:name], key: :body
  attribute :shortname
  attribute :url

  has_one :profile_photo, predicate: RDF::SCHEMA[:image] do
    obj = object.actor&.default_profile_photo
    if obj
      link(:self) do
        {
          meta: {
            '@type': RDF::SCHEMA[:image]
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
    end
    obj
  end

  has_one :user, predicate: RDF::ARGU[:user] do
    obj = object.user
    if obj
      link(:self) do
        {
          meta: {
            '@type': 'argu:user'
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
    end
    obj
  end

  has_one :actor, predicate: RDF::ARGU[:actor] do
    obj = object.actor&.profileable
    if obj
      link(:self) do
        {
          meta: {
            '@type': 'argu:actor'
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
    end
    obj
  end
end
