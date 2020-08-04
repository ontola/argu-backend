# frozen_string_literal: true

class Session < LinkedRails::Resource
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable

  attr_accessor :email, :r

  def iri_opts
    {r: r}
  end

  class << self
    def iri_template
      @iri_template ||= URITemplate.new('/u/sign_in{?r}')
    end
  end
end
