# frozen_string_literal: true

class ActiveBanner < Banner
  def iri_template_name
    :banners_iri
  end

  def owner_type
    'Banner'
  end

  class << self
    def find_sti_class(_type_name)
      ActiveBanner
    end

    def sti_name
      'Banner'
    end
  end
end
