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
end
