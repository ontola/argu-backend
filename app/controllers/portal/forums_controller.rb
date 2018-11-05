# frozen_string_literal: true

class Portal::ForumsController < EdgeableController
  include Createable::Controller

  private

  def create_includes
    [widget_sequence: :members]
  end

  def form_view_locals
    {
      resource: resource,
      controller_name.singularize.to_sym => resource
    }
  end

  def parent_resource
    Page.find_via_shortname_or_id(params[:page] || params[:page_id])
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      parent: parent_resource!
    )
  end

  def signals_failure
    super + [:"#{action_name}_ori_forum_failed"]
  end

  def signals_success
    super + [:"#{action_name}_ori_forum_successful"]
  end
end
