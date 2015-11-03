module ApplicationHelper
  include ActivityStringHelper, AlternativeNamesHelper, UsersHelper, StubbornCookie, MarkdownHelper
  EU_COUNTRIES = %w(BE BG CZ DK DE EE IE EL ES FR HR IT CY LV LT LU HU MT AT PL PT RO SI SK FI SE UK ME IS AL RS TR)

  # Uses Rollout to determine whether a feature is active for a given User
  def active_for_user?(feature, user)
    begin
      $rollout.active?(feature, user)
    rescue Redis::CannotConnectError => e
      Bugsnag.notify(e)
    end
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

  def user_identity_token(user)
    sign_payload({
                     user: user.id,
                     exp: 2.days.from_now.to_i,
                     iss: 'argu.co'
                 })
  end

  def sign_payload(payload)
    JWT.encode payload, Rails.application.secrets.jwt_encryption_token, 'HS256'
  end

  def decode_token(token, verify = false)
    JWT.decode(token, Rails.application.secrets.jwt_encryption_token, {algorithm: 'HS256'})[0]
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

  def r_to_url_options(r)
    url_options = Rails.application.routes.recognize_path(Addressable::URI.parse(URI.decode(r)).path)
    return url_options, "#{url_options[:controller]}_controller".camelize.safe_constantize
  end

  def remote_if_non_modern
    browser.modern? ? {'skip-pjax' => true} : {remote: true, 'skip-pjax' => true}
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
    current_profile.present? ? {} : {remote: true, 'skip-pjax' => true}
  end

  def resource
    @resource
  end

  def set_title(model= '', **options)
    title_string = seolized_title(model, **options)
    if request.env['HTTP_X_PJAX']
      raw "<title>#{title_string}</title>"
    else
      provide :title, title_string
    end
  end

  # Generates social media links for any resource for HyperDropdown
  def share_items(resource)
    url = url_for([resource, only_path: false])

    {
        title: t('share'),
        url: url,
        shareUrls: {
            facebook: ShareHelper.facebook_share_url(url),
            linkedIn: ShareHelper.linkedin_share_url(url, title: resource.display_name),
            twitter: ShareHelper.twitter_share_url(url, title: resource.display_name)
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

  def display_settings_items
    link_items = []

    link_items = [
        link_item(t('info_bar'), nil, fa: 'info', data: {'display-setting' => 'info_bar'}),
        link_item(t('images'), nil, fa: 'image', data: {'display-setting' => 'image'}),
        link_item(t('columns'), nil, fa: 'columns', data: {'display-setting' => 'columns'})
    ]

    dropdown_options(t('display'), [{items: link_items}], fa: 'fa-columns')
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
    _html = escape_once HTML_Truncator.truncate(adjusted_content, cutting_point, {length_in_chars: true, ellipsis: ('... ') })
    _html << url if adjusted_content.length > cutting_point
    _html
  end

end
