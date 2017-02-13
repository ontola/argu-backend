# frozen_string_literal: true
class VoteMatchSerializer < RecordSerializer
  attributes :name, :text

  has_many :voteables do
    link(:self) do
      {
        href: "#{object.context_id}/voteables",
        meta: {
          '@type': 'argu:motions'
        }
      }
    end
    meta do
      href = object.context_id
      {
        '@type': 'argu:collectionAssociation',
        '@id': "#{href}/voteables"
      }
    end
  end

  has_many :comparables do
    link(:self) do
      {
        href: "#{object.context_id}/comparables",
        meta: {
          '@type': 'argu:profiles'
        }
      }
    end
    meta do
      href = object.context_id
      {
        '@type': 'argu:collectionAssociation',
        '@id': "#{href}/comparables"
      }
    end
  end

  has_one :creator do
    obj = object.creator.profileable
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
          attributes: {
            '@context': {
              schema: 'http://schema.org/',
              name: 'schema:name'
            },
            '@type': 'schema:Person',
            name: obj.display_name
          }
        }
      }
    end
    obj
  end
end
