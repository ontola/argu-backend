# frozen_string_literal: true

class Banner < NewsBoy
  enhance Createable
  enhance Destroyable
  enhance Updateable
  include EdgeableShallow
  enhance ProfilePhotoable
  enhance CoverPhotoable
  include Uuidable

  belongs_to :forum, primary_key: :uuid
  belongs_to :publisher, class_name: 'User'

  enum audience: {guests: 0, users: 1, everyone: 3}

  validates :forum, :audience, presence: true
  alias parent forum
  alias edgeable_record forum

  def iri_opts
    super.merge(root_id: parent.root.url)
  end

  def shallow_parent
    forum
  end
end
