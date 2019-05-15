# frozen_string_literal: true

class WidgetsController < ServiceController
  skip_before_action :check_if_registered, only: :index

  private

  def index_collection
    @index_collection ||=
      LinkedRails::Sequence.new(
        policy_scope(parent_resource.widgets),
        id: collection_iri(parent_resource, :widgets)
      )
  end

  def index_includes_collection
    {members: Widget.preview_includes}
  end

  def resource_new_params
    {owner: parent_resource}
  end
end
