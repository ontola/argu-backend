# frozen_string_literal: true

class AccessToken < LinkedRails::Resource
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable

  attr_accessor :email, :r, :password

  def iri_opts
    {r: r}
  end

  class << self
    def iri_template
      @iri_template ||= URITemplate.new("/u/access_tokens{?r}")
    end
  end
end
