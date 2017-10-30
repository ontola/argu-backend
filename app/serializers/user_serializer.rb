# frozen_string_literal: true

class UserSerializer < RecordSerializer
  def service_or_self?
    service_scope? || object == scope&.user
  end

  attribute :display_name, predicate: RDF::SCHEMA[:name]
  attribute :about, predicate: RDF::SCHEMA[:description]
  attribute :url
  attribute :language, predicate: RDF::SCHEMA[:language], if: :service_scope?
  attribute :email, predicate: RDF::SCHEMA[:email], if: :service_or_self?
  has_many :email_addresses, if: :service_or_self? do
    link(:self) do
      {
        meta: {
          '@type': 'argu:emails'
        }
      }
    end
  end

  has_one :profile_photo, predicate: RDF::SCHEMA[:image] do
    obj = object.profile.default_profile_photo
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
    obj
  end

  has_one :vote_match_collection, predicate: RDF::ARGU[:voteMatches] do
    link(:self) do
      {
        href: "#{object.context_id}/vote_matches",
        meta: {
          '@type': 'argu:voteMatches'
        }
      }
    end
    meta do
      href = object.context_id
      {
        '@type': 'argu:collectionAssociation',
        '@id': "#{href}/vote_matches"
      }
    end
  end

  def vote_match_collection
    object.vote_match_collection(user_context: scope)
  end

  def about
    object.profile.about
  end

  def shortname
    object.url
  end
end
