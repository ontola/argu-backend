# frozen_string_literal: true

class ShortnamesController < ParentableController
  rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique

  private

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

    @parent_resource ||= LinkedRails.iri_mapper.resource_from_iri(destination_param, user_context)
  end

  def permit_params
    super.except(:destination)
  end

  def redirect_location
    settings_iri(authenticated_resource.root, tab: 'shortnames')
  end
end
