# frozen_string_literal: true

class ShortnamesController < ParentableController
  rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique

  private

  def ld_action_name(_view)
    ACTION_MAP[action_name.to_sym] || action_name.to_sym
  end

  def collection_options
    super.merge(association_base: unscoped_shortnames)
  end

  def create_execute
    update_execute
  end

  def destination_param
    return @destination_param if instance_variable_defined?(:@destination_param)
    return if params[:shortname].try(:[], :destination).blank?

    @destination_param = "#{tree_root.iri}/#{params[:shortname][:destination]}"
  end

  def parent_resource
    return tree_root if destination_param.blank?

    @parent_resource ||= LinkedRails.iri_mapper.resource_from_iri(destination_param)
  end

  def permit_params
    super.except(:destination, :unscoped)
  end

  def resource_new_params
    HashWithIndifferentAccess.new(
      primary: false,
      owner: parent_resource!,
      root_id: unscoped_param ? nil : parent_resource.root_id
    )
  end

  def redirect_location
    settings_iri(authenticated_resource.root, tab: 'shortnames')
  end

  def unscoped_param
    params[:shortname].try(:[], :unscoped)&.presence if current_user.is_staff?
  end

  def unscoped_shortnames
    ActsAsTenant.without_tenant do
      Kaminari.paginate_array(
        Shortname
          .joins("INNER JOIN edges ON edges.uuid = shortnames.owner_id AND shortnames.owner_type = 'Edge'")
          .where(edges: {root_id: parent_resource.uuid}, primary: false)
          .distinct
          .to_a
      )
    end
  end
end
