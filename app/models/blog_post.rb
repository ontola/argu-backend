# frozen_string_literal: true

class BlogPost < ApplicationRecord
  include Trashable, Attachable, HasLinks, Loggable, PublicActivity::Common,
          ActivePublishable, Edgeable, Happenable, Commentable, Ldable

  belongs_to :forum
  belongs_to :creator,
             class_name: 'Profile'
  belongs_to :publisher,
             class_name: 'User'

  contextualize_as_type 'argu:BlogPost'
  contextualize_with_id { |r| Rails.application.routes.url_helpers.blog_post_url(r, protocol: :https) }
  contextualize :display_name, as: 'schema:name'
  contextualize :description, as: 'schema:text'

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
