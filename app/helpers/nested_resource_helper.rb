# frozen_string_literal: true

# Helper to determine the parent of the nested resource
# It is to be used with {AuthorizedController} inherited resource controllers
# @note Has been designed with a single parent resource in mind (route wise)
# @author Fletcher91 <thom@argu.co>
module NestedResourceHelper
  include IRIHelper

  def parent_resource
    @parent_resource ||= parent_from_params(tree_root, params)
  end

  def parent_resource!
    parent_resource || raise(ActiveRecord::RecordNotFound)
  end

  # Extracts a parent resource from an Argu URI
  # @return [ApplicationRecord, nil] The parent resource corresponding to the iri, or nil if no parent is found
  def parent_from_iri(iri)
    root = TenantFinder.from_url(iri)
    return nil if root.blank?
    route_opts = Rails.application.routes.recognize_path(DynamicUriHelper.rewrite(iri, root))
    parent_from_params(root, route_opts) if parent_resource_key(route_opts)
  rescue ActionController::RoutingError
    nil
  end

  # Finds the parent resource based on the URL's :foo_id param
  # @note This method knows {Shortnameable}
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [ApplicationRecord, nil] A resource model if found
  def parent_from_params(root = tree_root, opts = params)
    return root if parent_resource_param(opts).blank? && opts[:collection].blank?

    opts = opts.dup
    opts[:class] = parent_resource_class(opts)
    opts[:id] = opts.delete(parent_resource_param(opts))
    parent_resource_or_collection(root, opts)
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
      opts_from_iri(resource_params[:parent])[:id]
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

  def parent_resource_or_collection(root, opts)
    resource = resource_from_opts(root, opts.merge(type: controller_name))
    return resource if opts[:collection].blank?

    parent_collection(resource, opts)
  end

  def parent_collection(resource, opts)
    collection_class = opts[:collection].classify.constantize
    collection_opts = collection_params(opts, collection_class)

    if resource.present?
      resource.send("#{opts[:collection].to_s.singularize}_collection", collection_opts)
    else
      collection_class.try(:root_collection, collection_opts)
    end
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
      opts_from_iri(resource_params[:parent])[:type]
    else
      key = parent_resource_key(opts)
      key[0..-4] if key
    end
  end

  # Return the params nested for the current resource
  # @example params in motions_controller
  #   params = {motion: {id: 1}}
  #   resource_params # => {id: 1}
  def resource_params
    params[controller_name.singularize].is_a?(Hash) ? params[controller_name.singularize] : {}
  end
end
