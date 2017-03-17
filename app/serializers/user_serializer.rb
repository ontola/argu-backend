# frozen_string_literal: true
class UserSerializer < RecordSerializer
  def service_or_self?
    service_scope? || object == scope&.user
  end

  attributes :display_name, :about, :url
  attribute :language, if: :service_scope?
  attribute :email, if: :service_or_self?

  has_one :profile_photo do
    obj = object.profile.default_profile_photo
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
          '@type': obj.context_type
        }
      }
    end
    obj
  end

  has_one :vote_match_collection do
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
