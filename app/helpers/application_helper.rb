# frozen_string_literal: true

require 'bcrypt'
require 'bcrypt/engine'
require 'stubborn_cookie'

module ApplicationHelper
  include JWTHelper
  include Devise::OmniAuth::UrlHelpers
  include StubbornCookie
  include UsersHelper
  include NamesHelper
  include ActivityHelper
  include UUIDHelper
  include VisibilityHelper

  def allowed_publish_types(resource)
    resource_policy = policy(resource)
    types =
      if resource_policy.moderator? || resource_policy.administrator? || resource_policy.staff?
        %i[direct draft schedule]
      else
        %i[direct draft]
      end
    types.map { |type| {label: t("publications.instance_type.#{type}"), value: type} }
  end

  def asset_present?(name)
    return Rails.application.assets_manifest.assets[name].present? unless Rails.env.development?
    Rails.application.assets.find_asset(name).present?
  end

  def awesome_time_ago_in_words(date)
    return if date.blank?
    if 1.day.ago < date
      distance_of_time_in_words(date, Time.current)
    elsif 1.year.ago < date
      date.strftime("%B #{date.day.ordinalize} %H:%M")
    else
      date.strftime('%Y-%m-%d %H:%M')
    end
  end

  def current_controller_js_path
    path = params[:controller].split('/')
    path[-1].sub!(/^/, '_')
    "dist/controllers/#{path.join('/')}_bundle.js"
  end

  def image_tag(source, options = {})
    source = 'data:image/gif;base64,R0lGODlhAQABAAAAACwAAAAAAQABAAA=' if source.nil?
    super
  end

  def user_identity_token(user)
    sign_payload(user: user.id,
                 exp: 2.days.from_now.to_i,
                 iss: 'argu.co')
  end

  # Merges a URI with a params Hash
  def merge_query_parameter(uri, params)
    uri =  URI.parse(uri)
    params = params.present? ? Hash[*params.split('=')] : {} if params.class != Hash

    new_query_ar = URI.decode_www_form(uri.query || '') << params.flatten
    uri.query = URI.encode_www_form(new_query_ar)
    uri.to_s
  end

  def organization_class
    return if try(:tree_root).blank?
    "organization-#{tree_root.url}"
  end

  # Used in forms for the 'r' system
  def remote_if_user(override = nil)
    if !override.nil?
      override ? {remote: override} : {}
    else
      current_user.guest? ? {} : {remote: true}
    end
  end

  # Used in forms for the 'r' system
  def remote_unless_user
    current_user.guest? ? {remote: true, turbolinks: true} : {}
  end

  def resource
    @resource
  end

  def set_title(model = '', **options)
    title_string = seolized_title(model, **options)
    provide :title, title_string
  end

  def sort_items_param(record)
    link_items = [
      sort_item(record, :popular, 'check-square-o'),
      sort_item(record, :created_at, 'clock-o'),
      sort_item(record, :updated_at, 'fire')
    ]

    dropdown_options(t("filtersort.#{sort_param_or_default}"), [{items: link_items}], fa: 'fa-sort')
  end

  def sort_item(record, type, icon)
    link_item(t("filtersort.#{type}"), record.iri(sort: type), fa: icon)
  end

  def sort_param_or_default
    params[:sort] || authenticated_resource.default_motion_sorting
  end

  def status_classes_for(resource)
    classes = []
    classes << 'draft' if resource.try(:is_draft?)
    classes << 'trashed' if resource.try(:is_trashed?)
    classes.compact.join(' ')
  end
end
