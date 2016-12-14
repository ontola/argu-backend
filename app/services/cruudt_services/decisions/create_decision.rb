# frozen_string_literal: true
class CreateDecision < PublishedCreateService
  def initialize(parent, attributes: {}, options: {})
    attributes[:decisionable_id] = parent.id
    attributes[:step] = parent.decisions.count
    super
  end

  private

  def after_save
    notify
  end

  def object_attributes=(obj)
    case obj
    when Activity
      obj.forum ||= resource.forum
      obj.owner ||= resource.creator
      obj.key ||= "#{resource.state}.happened"
      obj.recipient ||= resource.parent_model
      obj.is_published ||= false
    when Decision
      obj.forum ||= resource.forum
      obj.edge ||= obj.build_edge(
        user: resource.parent_model.publisher,
        parent: resource.parent_model.edge
      )
    end
  end

  def parent_columns
    %i(forum_id)
  end
end
