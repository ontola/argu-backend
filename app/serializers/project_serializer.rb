class ProjectSerializer < BaseSerializer
  attributes :display_name, :content

  has_many :phases
end
