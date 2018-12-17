# frozen_string_literal: true

class MoveForm < RailsLD::Form
  field :new_parent_id,
        max_count: 1,
        sh_in: ->(resource) { move_options(resource.form.target.edge) }

  def self.move_options(resource)
    case resource
    when Motion
      resource.root.forums.flat_map { |forum| [forum.iri] + forum.questions.map(&:iri) }
    when Forum
      Page.all.map(&:iri)
    else
      resource.root.forums.map(&:iri)
    end
  end
end
