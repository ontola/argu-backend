# frozen_string_literal: true

class ORIForum < Forum
  self.default_widgets = %i[]

  def iri_template_name
    :forums_iri
  end
end
