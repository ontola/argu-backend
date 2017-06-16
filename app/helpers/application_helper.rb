# frozen_string_literal: true

require 'bcrypt'
require 'bcrypt/engine'
require 'stubborn_cookie'

module ApplicationHelper
  include JWTHelper
  include TruncateHelper
  include Devise::OmniAuth::UrlHelpers
  include StubbornCookie
  include UsersHelper
  include NamesHelper
  include ActivityHelper

  # Uses Rollout to determine whether a feature is active for a given User
  def active_for_user?(feature, user)
    return true if Rails.env.test? || Rails.env.development?

    $rollout.active?(feature, user)
  rescue Redis::CannotConnectError => e
    Bugsnag.notify(e)
    nil
  end

  def allowed_publish_types(resource)
    types =
      if policy(resource)
           .permitted_nested_attributes(:edge_attributes, :argu_publication_attributes)
           .include?(:published_at)
        %i[direct draft schedule]
      else
        %i[direct draft]
      end
    types.map { |type| {label: t("publications.type.#{type}"), value: type} }
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

  def r_to_url_options(r)
    url_options = Rails.application.routes.recognize_path(Addressable::URI.parse(URI.decode(r)).path)
    [url_options, "#{url_options[:controller]}_controller".camelize.safe_constantize]
  rescue ActionController::RoutingError
    [nil, nil]
  end

  def remote_if_non_modern
    browser.modern? ? {turbolinks: 'false'} : {remote: true, turbolinks: 'false'}
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

  # Generates social media links for any resource for HyperDropdown
  def share_items(resource, opts = {})
    url = polymorphic_url(resource, only_path: false)
    if resource.edge.is_public?
      share_urls = {
        facebook: ShareHelper.facebook_share_url(url),
        linkedIn: ShareHelper.linkedin_share_url(url, title: resource.display_name),
        twitter: ShareHelper.twitter_share_url(url, title: resource.display_name),
        googlePlus: ShareHelper.googleplus_share_url(url),
        email: ShareHelper.email_share_url(url, title: resource.display_name)
      }
      share_urls[:whatsapp] = ShareHelper.whatsapp_share_url(url) if browser.device.mobile?
    else
      share_urls = {}
    end
    share_urls[:invite] = polymorphic_url([resource, :invite], only_path: false) if policy(resource).invite?

    {
      title: t('share'),
      url: url,
      shareUrls: share_urls,
      triggerClass: opts[:trigger_class]
    }
  end

  def sort_items
    link_items = [
      link_item(t('filtersort.updated_at'), nil, fa: 'fire', data: {'sort-value' => 'updated_at'}),
      link_item(t('filtersort.created_at'), nil, fa: 'clock-o', data: {'sort-value' => 'created_at'}),
      link_item(t('filtersort.name'), nil, fa: 'sort-alpha-asc', data: {'sort-value' => 'name'}),
      link_item(t('filtersort.vote_count'), nil, fa: 'check-square-o', data: {'sort-value' => 'vote_count'}),
      link_item(t('filtersort.random'), nil, fa: 'gift', data: {'sort-value' => 'random'}, className: 'sort-random')
    ]

    dropdown_options(t('filtersort.sort'), [{items: link_items}], fa: 'fa-sort')
  end

  def filter_items
    link_items = [
      link_item(t('filtersort.all'), nil, fa: 'check', data: {'filter-value' => ''}),
      link_item(t('filtersort.questions'), nil, fa: 'question', data: {'filter-value' => 'question'}),
      link_item(t('filtersort.motions'), nil, fa: 'lightbulb-o', data: {'filter-value' => 'motion'})
    ]

    dropdown_options(t('filtersort.filter'), [{items: link_items}], fa: 'fa-filter')
  end

  def status_classes_for(resource)
    classes = []
    classes << 'draft' if resource.try(:is_draft?)
    classes << 'trashed' if resource.try(:is_trashed?)
    classes.compact.join(' ')
  end

  def visible_for_group_ids(resource)
    @visible_for_group_ids ||= {}
    @visible_for_group_ids[resource] ||= resource.edge.granted_group_ids(:spectator)
  end

  def visible_for_string(resource)
    groups = visible_for_group_ids(resource)
    return t('groups.visible_for_everybody') if groups.include?(-1)
    t('groups.visible_for', groups: Group.find(groups).pluck(:name).to_sentence)
  end

  def visibility_icon(resource)
    visible_for_group_ids(resource).include?(-1) ? 'globe' : 'group'
  end

  def display_settings_items
    link_items = [
      link_item(t('info_bar'), nil, fa: 'info', data: {'display-setting' => 'info_bar'}),
      link_item(t('images'), nil, fa: 'image', data: {'display-setting' => 'image'}),
      link_item(t('columns'), nil, fa: 'columns', data: {'display-setting' => 'columns'})
    ]

    dropdown_options(t('display'), [{items: link_items}], fa: 'fa-columns')
  end

  # :nodoc:
  def can_show_display_name?(preview)
    if preview.respond_to?(:parent_model)
      preview.parent_model.open?
    elsif preview.class == Profile
      true
    end
  end
end
