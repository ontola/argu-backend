# frozen_string_literal: true

class GrantedGroupsController < AuthorizedController
  skip_before_action :check_if_registered, only: :index

  private

  def authorize_action
    authorize parent_resource!, :show?
  end

  def index_collection
    @index_collection ||=
      LinkedRails::Sequence.new(
        user_context.grant_tree.granted_groups(parent_resource!.persisted_edge),
        id: index_iri
      )
  end
end
