# frozen_string_literal: true

class Token < LinkedRails::Resource
  enhance LinkedRails::Enhancements::Actionable
  enhance LinkedRails::Enhancements::Creatable

  attr_accessor :email, :r, :password

  def iri_opts
    {r: r}
  end

  class << self
    def iri_template
      @iri_template ||= URITemplate.new("/u/#{route_key}{?r}")
    end
  end
end
