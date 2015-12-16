module ShareHelper
  SHARE_PLATFORMS = %i(facebook twitter linkedin googleplus)

  # https://developers.facebook.com/docs/sharing/reference/feed-dialog/v2.3
  def self.facebook_share_url(url, options = {})
    "https://www.facebook.com/dialog/feed?app_id=#{Rails.application.secrets.facebook_key}&display=popup&link=#{CGI.escape(url)}&redirect_uri=#{CGI.escape(url)}"
  end

  # https://dev.twitter.com/web/intents
  def self.twitter_share_url(url, options = {})
    "https://twitter.com/intent/tweet?url=#{CGI.escape(url)}&text=#{CGI.escape(options[:title])}%20%40argu_co"
  end

  # https://developer.linkedin.com/docs/share-on-linkedin
  def self.linkedin_share_url(url, options= {})
    "http://www.linkedin.com/shareArticle?mini=true&url=#{CGI.escape(url)}&title=#{CGI.escape(options[:title])}"
  end

  # https://developers.google.com/+/web/share/#share-link
  def self.googleplus_share_url(url, options= {})
    "https://plus.google.com/share?url=#{CGI.escape(url)}"
  end

end
