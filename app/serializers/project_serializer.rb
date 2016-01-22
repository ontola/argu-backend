class ProjectSerializer < BaseSerializer
  attributes :display_name, :content

  has_many :phases
  has_many :blog_posts
end
