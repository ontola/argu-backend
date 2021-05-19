# frozen_string_literal: true

# Helper to determine the parent of the nested resource
# It is to be used with {AuthorizedController} inherited resource controllers
# @note Has been designed with a single parent resource in mind (route wise)
# @author Fletcher91 <thom@argu.co>
module NestedResourceHelper
  include UriTemplateHelper

  def params_for_parent
    params.dup
  end

  def parent_resource
    @parent_resource ||= linked_record_parent || parent_from_params(params_for_parent)
  end

  def linked_record_parent
    return unless request.path.start_with?('/resource/')

    LinkedRecord.find_or_initialize_by_iri(params_for_parent[:iri])
  end

  def parent_resource!
    parent_resource || raise(ActiveRecord::RecordNotFound)
  end

  # Finds a 'resource key' from a params Hash
  # @example Resource key from motion_id
  #   params = {motion_id: 1}
  #   parent_resource_key # => :motion_id
  def parent_resource_key(hash)
    hash
      .keys
      .reject { |k| k.to_s == 'root_id' }
      .reverse
      .find { |k| /_id/ =~ k }
  end

  # Extracts a parent resource from an Argu URI
  # @return [ApplicationRecord, nil] The parent resource corresponding to the iri, or nil if no parent is found
  def parent_from_iri(iri)
    route_opts = Rails.application.routes.recognize_path(DynamicUriHelper.rewrite(iri))
    parent_from_params(route_opts) if parent_resource_key(route_opts)
  rescue ActionController::RoutingError
    nil
  end

  # Finds the parent resource based on the URL's :foo_id param
  # @note This method knows {Shortnameable}
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [ApplicationRecord, nil] A resource model if found
  def parent_from_params(opts = params_for_parent)
    return ActsAsTenant.current_tenant if parent_resource_param(opts).blank? && opts[:collection].blank?

    opts = opts.dup
    opts[:class] = parent_resource_class(opts)
    opts[:id] = opts.delete(parent_resource_param(opts))
    parent_resource_or_collection(opts)
  end

  # Extracts the resource id from a params hash
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [String] The resource id
  # @example Resource id from parent iri
  #   params = {parent: 'https://argu.co/m/1'}
  #   parent_id_from_params # => '1'
  # @example Resource class from motion_id
  #   params = {motion_id: 1}
  #   parent_id_from_params # => '1'
  def parent_id_from_params(opts = params)
    if resource_params[:parent].present?
      LinkedRails.iri_mapper.opts_from_iri(resource_params[:parent])[:id]
    else
      opts[parent_resource_param(opts)]
    end
  end

  # Determines the parent resource's class from the request
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [ApplicationRecord] The parent resource class object
  # @see #parent_resource_klass
  def parent_resource_class(opts = params)
    parent_resource_klass(opts)
  end

  # Constantizes a class string from the params hash
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [ApplicationRecord] The parent resource class object
  # @note Whether the given parent is allowed for the requested resource is not validated here.
  def parent_resource_klass(opts = params)
    ApplicationRecord.descendants.detect { |m| m.to_s == parent_resource_type(opts)&.classify }
  end

  def parent_resource_or_collection(raw_opts)
    opts = raw_opts.merge(type: controller_name)
    resource = LinkedRails.iri_mapper.resource_from_opts(opts)
    return resource if opts[:collection].blank?

    parent_collection(resource, opts)
  end

  # Extracts the parent resource param from the url to get to its value
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [Symbol] The resource param
  # @see #parent_resource_key
  def parent_resource_param(opts = params)
    parent_resource_key(opts)
  end

  # Extracts the resource type string from a params hash
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [String] The resource type string
  # @example Resource type from parent iri
  #   params = {parent: 'https://argu.co/m/1'}
  #   parent_resource_type # => 'motion'
  # @example Resource type from motion_id
  #   params = {motion_id: 1}
  #   parent_resource_type # => 'motion'
  def parent_resource_type(opts = params)
    if resource_params[:parent].present?
      LinkedRails.iri_mapper.opts_from_iri(resource_params[:parent])[:type]
    else
      key = parent_resource_key(opts)
      key[0..-4] if key
    end
  end

  def path_to_url(path)
    return path unless relative_path?(path)

    port = [80, 443].include?(request.port) ? nil : request.port
    URI::Generic.new(request.scheme, nil, request.host, port, nil, path, nil, nil, nil).to_s
  end

  def relative_path?(string)
    string.is_a?(String) && string.starts_with?('/') && !string.starts_with?('//')
  end

  # Return the params nested for the current resource
  # @example params in motions_controller
  #   params = {motion: {id: 1}}
  #   resource_params # => {id: 1}
  def resource_params
    params[controller_name.singularize].is_a?(Hash) ? params[controller_name.singularize] : {}
  end
end
