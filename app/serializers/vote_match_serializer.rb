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

  has_many :vote_comparables do
    link(:self) do
      {
        href: "#{object.context_id}/vote_comparables",
        meta: {
          '@type': 'argu:profiles'
        }
      }
    end
    meta do
      href = object.context_id
      {
        '@type': 'argu:collectionAssociation',
        '@id': "#{href}/vote_comparables"
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

  has_one :vote_compare_result do
    link(:related) do
      {
        href: "https://#{Rails.application.config.host}/compare/votes?vote_match=#{object.id}",
        meta: {
          '@type': 'argu:voteCompareResult'
        }
      }
    end
    {
      id: "https://#{Rails.application.config.host}/compare/votes?vote_match=#{object.id}",
      type: 'argu:voteCompareResult'
    }
  end
end
