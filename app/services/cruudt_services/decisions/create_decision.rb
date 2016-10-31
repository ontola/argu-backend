# frozen_string_literal: true
class CreateDecision < PublishedCreateService
  def initialize(parent, attributes: {}, options: {})
    attributes[:decisionable] = parent
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
      obj.recipient ||= resource.decisionable.owner
      obj.is_published ||= false
    when Decision
      obj.forum ||= resource.forum
      obj.edge ||= obj.build_edge(
        user: resource.decisionable.publisher,
        parent: resource.decisionable.edge
      )
    end
  end

  def parent_columns
    %i(forum_id)
  end
end
