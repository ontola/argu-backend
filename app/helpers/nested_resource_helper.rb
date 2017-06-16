# frozen_string_literal: true

# Helper to determine the parent of the nested resource
# It is to be used with {AuthorizedController} inherited resource controllers
# @note Has been designed with a single parent resource in mind (route wise)
# @author Fletcher91 <thom@argu.co>
module NestedResourceHelper
  include IRIHelper

  def parent_resource
    @parent_resource ||= parent_id_from_params(params).present? ? parent_from_params(params) : super
  end

  # Finds the parent resource based on the URL's :foo_id param
  # @note This method knows {Shortnameable}
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [ApplicationRecord, nil] A resource model if found
  def parent_from_params(opts = params)
    if parent_resource_class(opts).try(:shortnameable?)
      parent_resource_class(opts)&.find_via_shortname_or_id(parent_id_from_params(opts))
    else
      parent_resource_class(opts)&.find_by(id: parent_id_from_params(opts))
    end
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
      id_and_type_from_iri(resource_params[:parent])[:id]
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

  # Finds a 'resource key' from a params Hash
  # @example Resource key from motion_id
  #   params = {motion_id: 1}
  #   parent_resource_key # => :motion_id
  def parent_resource_key(hash)
    hash.keys.reverse.find { |k| /_id/ =~ k }
  end

  # Constantizes a class string from the params hash
  # @param opts [Hash, nil] The parameters, {ActionController::StrongParameters#params} is used when not given.
  # @return [ApplicationRecord] The parent resource class object
  # @note Whether the given parent is allowed for the requested resource is not validated here.
  def parent_resource_klass(opts = params)
    ApplicationRecord.descendants.detect { |m| m.to_s == parent_resource_type(opts).gsub('canonical_', '').classify }
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
      id_and_type_from_iri(resource_params[:parent])[:type]
    else
      parent_resource_key(opts)[0..-4]
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
