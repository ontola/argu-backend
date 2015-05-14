module Attribution
  extend ActiveSupport::Concern
  included do
  end

  # noinspection RubySuperCallWithoutSuperclassInspection
  def attribution
    _attr = picture.url.include?('default_banner') ? Setting.get(:default_banner_attribution) : super
    _attr.blank? ? '' : "Photo: #{_attr}"
  end

  module ClassMethods
  end
end
