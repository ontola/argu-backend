# frozen_string_literal: true
class ProjectSerializer < BaseSerializer
  include Motionable::Serlializer
  include Questionable::Serlializer
  attributes :display_name, :content

  has_many :phases
  has_many :blog_posts
end
