# frozen_string_literal: true
class ConversionsController < ApplicationController
  include ConvertibleHelper
  helper_method :collect_banners

  # GET /edge/:edge_id/conversion/new
  def new
    @edge = Edge.find(params[:edge_id])
    authorize @edge.owner, :convert?
    @conversion = Conversion.new edge: @edge, klass: convertible_class_names(@edge.owner).first
    authorize @conversion, :new?

    render :new
  end

  # POST /edge/:edge_id/conversion
  # POST /edge/:edge_id/conversion.json
  def create
    @edge = Edge.find(params[:edge_id])
    authorize @edge.owner, :convert?

    create_service.on(:create_conversion_successful) do |conversion|
      respond_to do |format|
        format.html do
          redirect_to @edge.owner, notice: t('type_convert_success',
                                             type: t("#{@edge.owner_type.underscore}.type"))
        end
        format.json { render :show, status: :created, location: conversion }
      end
    end
    create_service.on(:create_conversion_failed) do |conversion|
      respond_to do |format|
        format.html { render :new }
        format.json { render json: conversion.errors, status: :unprocessable_entity }
      end
    end
    create_service.commit
  end

  private

  def create_service
    @create_service ||= CreateConversion.new(
      Conversion.new(edge: @edge),
      attributes: permit_params,
      options: service_options
    )
  end

  def collect_banners
  end

  def permit_params
    params.require(:conversion).permit(*policy(@conversion || Conversion).permitted_attributes)
  end

  def service_options(options = {})
    {
      creator: current_profile,
      publisher: current_user
    }.merge(options)
  end
end
