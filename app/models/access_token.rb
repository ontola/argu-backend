# frozen_string_literal: true

class AccessToken < LinkedRails::Resource
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable

  attr_accessor :email, :redirect_url, :password

  def iri_opts
    {redirect_url: redirect_url}
  end

  class << self
    def iri_template
      @iri_template ||= URITemplate.new('/u/access_tokens{?redirect_url}')
    end
  end
end
