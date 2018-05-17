# frozen_string_literal: true

class CreateDecision < PublishedCreateService
  def initialize(parent, attributes: {}, options: {})
    attributes[:step] = parent.decisions.count
    if attributes['forwarded_user_id']
      attributes[:forwarded_user] = User.find_via_shortname_or_id(attributes.delete('forwarded_user_id'))
    end
    super
  end

  private

  def after_save
    notify
  end

  def object_attributes=(obj)
    case obj
    when Activity
      obj.owner ||= resource.creator
      obj.key ||= "#{resource.state}.happened"
      obj.recipient ||= resource.parent_model
      obj.recipient_edge = obj.recipient.edge
      obj.trackable_edge = obj.trackable.edge
    when Decision
      obj.edge ||= obj.build_edge(
        user: resource.parent_model.publisher,
        parent: resource.parent_model.edge
      )
    end
  end

  def prepare_argu_publication_attributes
    super
    return if @attributes['state'] == 'forwarded'
    @attributes[:edge_attributes][:argu_publication_attributes][:follow_type] = 'news'
  end
end
