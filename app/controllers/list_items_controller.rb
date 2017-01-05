# frozen_string_literal: true
class ListItemsController < AuthorizedController
  include NestedResourceHelper

  def index
    skip_verify_policy_scoped(true)
    authorize get_parent_resource, :show?

    relationship = get_parent_resource
                     .class
                     .reflect_on_all_associations
                     .map(&:name)
                     .detect { |name| name == params[:relationship] }

    collection = Collection.new(
      association: relationship,
      id: url_for([get_parent_resource, relationship]),
      member: get_parent_resource.send(relationship),
      parent: get_parent_resource,
      title: relationship.to_s.humanize
    )
    respond_to do |format|
      format.json_api do
        render json: collection
      end
    end
  end
end
