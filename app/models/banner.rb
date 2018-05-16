# frozen_string_literal: true

class Banner < NewsBoy
  include EdgeableShallow
  include Loggable
  include ProfilePhotoable
  include Photoable

  belongs_to :forum
  belongs_to :publisher, class_name: 'User'

  enum audience: {guests: 0, users: 1, everyone: 3}

  validates :forum, :audience, presence: true
  alias parent_model forum
  alias edgeable_record forum

  def iri_opts
    super.merge(root_id: parent_model.root.url)
  end

  def shallow_parent
    forum.edge
  end
end
