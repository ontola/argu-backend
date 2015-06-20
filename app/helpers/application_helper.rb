module ApplicationHelper
  include ActivityStringHelper, AlternativeNamesHelper, UsersHelper
  EU_COUNTRIES = %w(BE BG CZ DK DE EE IE EL ES FR HR IT CY LV LT LU HU MT AT PL PT RO SI SK FI SE UK ME IS AL RS TR)

  # Uses Rollout to determine whether a feature is active for a given User
  def active_for_user?(feature, user)
    begin
      $rollout.active?(feature, user)
    rescue RuntimeError => e
      Rails.logger.error 'Redis not available'
      ::Bugsnag.notify(e, {
          :severity => 'error',
      })
    end
  end

  def analytics_token
    salt = current_user.salt
    ::BCrypt::Engine.hash_secret("#{current_user.id}#{current_user.created_at}", salt).from(30)
  end

  def awesome_time_ago_in_words (date)
    if date.present?
      if 1.day.ago < date
        distance_of_time_in_words(date, Time.now)
      elsif 1.year.ago < date
        date.strftime("%B #{date.day.ordinalize} %H:%M")
      else
        date.strftime('%Y-%m-%d %H:%M')
      end
    end
  end

  def encrypt_payload(payload)
    JWT.encode payload, Rails.application.secrets.jwt_encryption_token, 'HS256'
  end

  def decrypt_token(token)
    JWT.decode(token, Rails.application.secrets.jwt_encryption_token, 'HS256')[0]
  end


  # Merges a URI with a params Hash
  def merge_query_parameter(uri, params)
    uri =  URI.parse(uri)
    if params.class != Hash
      params = params.present? ? Hash[*params.split('=')] : Hash.new
    end

    new_query_ar = URI.decode_www_form(uri.query || '') << params.flatten
    uri.query = URI.encode_www_form(new_query_ar)
    uri.to_s
  end

  def remote_if_non_mobile
    browser.mobile? ? {'skip-pjax' => true} : {remote: true, 'skip-pjax' => true}
  end

  # Used in forms for the 'r' system
  def remote_if_user
    current_profile.present? ? {remote: true} : {}
  end

  # Used in forms for the 'r' system
  def remote_unless_user
    current_profile.present? ? {} : {remote: true, 'skip-pjax' => true}
  end

  def resource
    @resource
  end

  def set_title(model= '')
    title_string = seolized_title(model)
    if request.env['HTTP_X_PJAX']
      raw "<title>#{title_string}</title>"
    else
      provide :title, title_string
    end
  end

  # Generates social media links for any resource for HyperDropdown
  def share_items(resource)
    link_items = []
    url = url_for([resource, only_path: false])

    #link_items << fb_share_item('Facebook', ShareHelper.facebook_share_url(url), fa: 'facebook', class: 'fb-share-dialog', data: {share_url: url})
    link_items << item('fb_share', 'Facebook', ShareHelper.facebook_share_url(url), data: {share_url: url, title: resource.display_name})
    link_items << link_item('Twitter', ShareHelper.twitter_share_url(url, title: resource.display_name), fa: 'twitter')
    link_items << link_item('LinkedIn', ShareHelper.linkedin_share_url(url, title: resource.display_name), fa: 'linkedin')

    dropdown_options(t('share'), [{items: link_items}], fa: 'fa-share-alt')
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

    dropdown_options(t('filtersort.sort') + ' ▼', [{items: link_items}], fa: 'fa-sort')
  end

  def process_cover_photo(object, _params)
    if params[object.class.name.downcase][:cover_photo].present?
      object.assign_attributes(_params.except(:cover_photo))
      if object.valid?
        object.remove_cover_photo!
        return object.save.to_s
      end
    end
    false
  end

  # Generates a link to the Profile's profileable
  # Either a Page or a User
  def dual_profile_path(profile)
    if profile.profileable.class == User
      user_path(profile.profileable)
    elsif profile.profileable.class == Page
      page_path(profile.profileable)
    else
      'deleted'
    end
  end

  # Generates a link to the Profile's profileable edit action
  # Either a Page or a User
  def dual_profile_edit_path(profile)
    if profile.profileable.class == User
      edit_user_path(profile.profileable)
    elsif profile.profileable.class == Page
      #edit_page_path?
      page_path(profile.profileable)
    else
      'deleted'
    end
  end

  # :nodoc:
  def can_show_display_name?(preview)
    if preview.respond_to?(:get_parent)
      preview.get_parent.model.open?
    elsif preview.class == Profile
      true
    end
  end


  # TODO: Something something instance variable with Redcarpet
  def markdown_to_html(markdown)
    Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new(filter_html: false, escape_html: true),
        {tables: false, fenced_code_blocks: false, no_styles: true, escape_html: true, autolink: true, lax_spacing: true}
    ).render(markdown).html_safe
  end

  def markdown_to_plaintext(markdown)
    require 'redcarpet/render_strip'

    Redcarpet::Markdown.new(
        Redcarpet::Render::StripDown.new,
        {tables: false, fenced_code_blocks: false, no_styles: true, escape_html: true, autolink: false, lax_spacing: true}
    ).render(markdown)
  end


  def safe_truncated_text(contents, url, cutting_point = 220)
    _html = escape_once HTML_Truncator.truncate(markdown_to_plaintext(contents), cutting_point, {length_in_chars: true, ellipsis: ('... ') })
    _html << url if _html.length > cutting_point
    _html
  end

end
