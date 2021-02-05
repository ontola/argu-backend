# frozen_string_literal: true

class ApplicationActionList < LinkedRails::Actions::List
  extend UriTemplateHelper
  include UriTemplateHelper

  def available_actions
    return {} if user_context&.system_scope?

    super
  end
end
