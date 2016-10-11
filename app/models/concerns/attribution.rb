# frozen_string_literal: true
module Attribution
  extend ActiveSupport::Concern
  included do
  end

  # noinspection RubySuperCallWithoutSuperclassInspection
  def attribution
    attr = picture.url.include?('default_banner') ? Setting.get(:default_banner_attribution) : super
    attr.blank? ? '' : "Photo: #{attr}"
  end

  module ClassMethods
  end
end
