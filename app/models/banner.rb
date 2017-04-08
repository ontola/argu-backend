# frozen_string_literal: true
class Banner < NewsBoy
  include Photoable, ProfilePhotoable, Loggable, Edgeable::Shallow

  def initialize(*opts)
    super
    @edge = Edge.new(parent: forum.edge, owner: self)
  end

  belongs_to :forum
  belongs_to :publisher, class_name: 'User'

  enum audience: {guests: 0, users: 1, members: 2, everyone: 3}

  validates :forum, :audience, presence: true
  # validates :sample_size, min: 1, max: 100, default: 100
end
