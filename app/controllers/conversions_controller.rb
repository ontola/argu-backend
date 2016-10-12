# frozen_string_literal: true
class ConversionsController < ApplicationController
  include ConvertibleHelper
  helper_method :collect_banners

  before_action :verify_convertible_edge

  # GET /edge/:edge_id/conversion/new
  def new
    authorize resource.edge.owner, :convert?
    authorize resource, :new?
    render :new, locals: {conversion: resource}
  end

  # POST /edge/:edge_id/conversion
  # POST /edge/:edge_id/conversion.json
  def create
    authorize resource.edge.owner, :convert?
    authorize resource, :new?

    create_service.on(:create_conversion_successful) do |conversion|
      respond_to do |format|
        format.html do
          redirect_to conversion.edge.owner,
                      notice: t('type_convert_success',
                                type: t("#{conversion.edge.owner_type.underscore}.type"))
        end
        format.json { render :show, status: :created, location: conversion }
      end
    end
    create_service.on(:create_conversion_failed) do |conversion|
      respond_to do |format|
        format.html { render :new, locals: {conversion: conversion} }
        format.json { render json: conversion.errors, status: :unprocessable_entity }
      end
    end
    create_service.commit
  end

  private

  def resource
    @resource ||=
      case action_name
      when 'create'
        create_service.resource
      when 'new'
        new_resource_from_params
      end
  end

  def collect_banners
  end

  def convertible_edge
    @convertible_edge ||= Edge.find(params[:edge_id])
  end

  def create_service
    @create_service ||= CreateConversion.new(
      Conversion.new(edge: convertible_edge),
      attributes: permit_params,
      options: service_options
    )
  end

  def permit_params
    params.require(:conversion).permit(*policy(new_resource_from_params).permitted_attributes)
  end

  def new_resource_from_params
    Conversion.new(edge: convertible_edge, klass: convertible_class_names(convertible_edge.owner).first)
  end

  def service_options(options = {})
    {
      creator: current_profile,
      publisher: current_user
    }.merge(options)
  end

  def verify_convertible_edge
    return if convertible_edge.owner.is_convertible?
    respond_to do |format|
      format.html { render 'status/422', status: 422 }
      format.json do
        render status: 422,
               json: {
                 notifications: [
                   {
                     type: :error,
                     message: "#{convertible_edge.owner} is not convertible"
                   }
                 ]
               }
      end
    end
  end
end
