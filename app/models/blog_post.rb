# frozen_string_literal: true

class BlogPost < Edgeable::Content
  include Commentable
  include Happenable
  include ActivePublishable
  include HasLinks
  include Attachable

  belongs_to :forum
  belongs_to :creator,
             class_name: 'Profile'
  belongs_to :publisher,
             class_name: 'User'

  counter_cache true
  parentable :motion, :question, :project

  validates :content, presence: true, length: {minimum: 2}
  validates :title, presence: true, length: {minimum: 2, maximum: 110}
  validates :creator, presence: true

  alias_attribute :description, :content
  alias_attribute :display_name, :title
  attr_accessor :happened_at
  delegate :happened_at, to: :happening, allow_nil: true
end
