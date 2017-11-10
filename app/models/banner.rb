# frozen_string_literal: true

class Banner < NewsBoy
  include Edgeable::Shallow
  include Loggable
  include ProfilePhotoable
  include Photoable

  belongs_to :forum
  belongs_to :publisher, class_name: 'User'

  enum audience: {guests: 0, users: 1, members: 2, everyone: 3}

  validates :forum, :audience, presence: true
  alias parent_model forum

  def shallow_parent
    forum.edge
  end
end
