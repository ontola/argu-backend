require 'bcrypt'
require 'bcrypt/engine'

module ApplicationHelper
  include ActivityStringHelper, AlternativeNamesHelper, UsersHelper, StubbornCookie, MarkdownHelper
  EU_COUNTRIES = %w(BE BG CZ DK DE EE IE EL ES FR HR IT CY LV
                    LT LU HU MT AT PL PT RO SI SK FI SE UK ME IS AL RS TR).freeze

  # Uses Rollout to determine whether a feature is active for a given User
  def active_for_user?(feature, user)
    $rollout.active?(feature, user)
  rescue Redis::CannotConnectError => e
    Bugsnag.notify(e)
    nil
  end

  def analytics_token
    salt = current_user.salt
    ::BCrypt::Engine.hash_secret("#{current_user.id}#{current_user.created_at}", salt).from(30)
  end

  def awesome_time_ago_in_words (date)
    if date.present?
      if 1.day.ago < date
        distance_of_time_in_words(date, Time.current)
      elsif 1.year.ago < date
        date.strftime("%B #{date.day.ordinalize} %H:%M")
      else
        date.strftime('%Y-%m-%d %H:%M')
      end
    end
  end

  def policy_with_tenant!(tenant, record)
    uc = UserContext.new(
      current_user,
      current_profile,
      session,
      tenant,
      platform_open: platform_open?,
      within_user_cap: within_user_cap?)
    Pundit.policy!(uc, record)
  end

  def user_identity_token(user)
    sign_payload(user: user.id,
                 exp: 2.days.from_now.to_i,
                 iss: 'argu.co')
  end

  def sign_payload(payload)
    JWT.encode payload, Rails.application.secrets.jwt_encryption_token, 'HS256'
  end

  def decode_token(token, verify = false)
    JWT.decode(token, Rails.application.secrets.jwt_encryption_token, algorithm: 'HS256')[0]
  end

  # Merges a URI with a params Hash
  def merge_query_parameter(uri, params)
    uri =  URI.parse(uri)
    params = params.present? ? Hash[*params.split('=')] : {} if params.class != Hash

    new_query_ar = URI.decode_www_form(uri.query || '') << params.flatten
    uri.query = URI.encode_www_form(new_query_ar)
    uri.to_s
  end

  def follow_dropdown_items(resource, opts = {})
    opts = {
      follow_types: [:reactions, :news, :never]
    }.merge(opts)
    items = []
    follow_type = current_user.following_type(resource.edge)
    opts[:follow_types].each do |type|
      items << link_item(t("notifications.receive.#{type}"),
                         follows_path(gid: resource.edge.id, follow_type: type),
                         fa: follow_type == type.to_s ? 'circle' : 'circle-o',
                         data: {
                           method: type == :never ? 'DELETE' : 'POST'
                         })
    end
    icon = case follow_type
           when 'never'
             'fa-bell-slash-o'
           when 'reactions'
             'fa-bell'
           else
             'fa-bell-o'
           end
    dropdown_options(t("notifications.receive.#{follow_type}"),
                     [{items: items}], fa: icon, triggerClass: opts[:trigger_class])
  end

  def r_to_url_options(r)
    url_options = Rails.application.routes.recognize_path(Addressable::URI.parse(URI.decode(r)).path)
    return url_options, "#{url_options[:controller]}_controller".camelize.safe_constantize
  end

  def remote_if_non_modern
    browser.modern? ? {turbolinks: false} : {remote: true, turbolinks: false}
  end

  # Used in forms for the 'r' system
  def remote_if_user(override = nil)
    if override != nil
      override ? {remote: override} : {}
    else
      current_profile.present? ? {remote: true} : {}
    end
  end

  # Used in forms for the 'r' system
  def remote_unless_user
    current_profile.present? ? {} : {remote: true, turbolinks: true}
  end

  def resource
    @resource
  end

  def set_title(model= '', **options)
    title_string = seolized_title(model, **options)
    provide :title, title_string
  end

  # Generates social media links for any resource for HyperDropdown
  def share_items(resource)
    url = polymorphic_url(resource, only_path: false)

    {
      title: t('share'),
      url: url,
      shareUrls: {
          facebook: ShareHelper.facebook_share_url(url),
          linkedIn: ShareHelper.linkedin_share_url(url, title: resource.display_name),
          twitter: ShareHelper.twitter_share_url(url, title: resource.display_name),
          googlePlus: ShareHelper.googleplus_share_url(url)
      }
    }
  end

  def sort_items
    link_items = []

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
    link_items = []

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
    if preview.respond_to?(:get_parent)
      preview.get_parent.model.open?
    elsif preview.class == Profile
      true
    end
  end

  def safe_truncated_text(contents, url, cutting_point = 220)
    adjusted_content = markdown_to_plaintext(contents)
    html = escape_once HTML_Truncator.truncate(adjusted_content,
                                               cutting_point,
                                               length_in_chars: true,
                                               ellipsis: '... ')
    html << url if adjusted_content.length > cutting_point
    html
  end
end
