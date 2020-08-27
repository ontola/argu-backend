# frozen_string_literal: true

class Session < LinkedRails::Resource
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable

  attr_accessor :email, :redirect_url

  def iri_opts
    {redirect_url: redirect_url}
  end

  class << self
    def iri_template
      @iri_template ||= URITemplate.new('/u/sign_in{?redirect_url}')
    end
  end
end
