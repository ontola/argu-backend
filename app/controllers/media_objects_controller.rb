# frozen_string_literal: true

class MediaObjectsController < ParentableController
  skip_before_action :check_if_registered, only: :index

  private

  def authorize_action
    return super unless action_name == 'index'
    authorize parent_resource, :index_children?, controller_name
  end

  def current_forum
    @current_forum ||= parent_resource.try(:parent_model, :forum)
  end

  def index_collection_association
    'attachment_collection'
  end

  def tree_root_id
    @tree_root_id ||=
      case action_name
      when 'new', 'create', 'index'
        parent_edge&.root_id
      else
        resource_by_id&.about&.try(:edge)&.root_id
      end
  end
end
