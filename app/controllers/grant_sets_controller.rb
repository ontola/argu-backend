# frozen_string_literal: true

class GrantSetsController < AuthorizedController
  skip_before_action :check_if_registered, only: :index

  private

  def resource_by_id
    @resource_by_id ||=
      if (/[a-zA-Z]/i =~ params[:id]).nil?
        GrantSet.find_by(id: params[:id])
      else
        GrantSet.find_by(title: params[:id])
      end
  end

  def index_collection
    @index_collection ||=
      LinkedRails::Sequence.new(
        user_context.grant_tree.grant_sets(parent_resource!.persisted_edge, group_ids: current_profile.group_ids),
        id: index_iri
      )
  end

  def index_includes_collection
    {}
  end
end
