# frozen_string_literal: true

module RecognizePathHelper
  def recognize_path(path, _environment = {})
    path = DynamicUriHelper.revert(path, ActsAsTenant.current_tenant)
    super
  end
end

ActionDispatch::Routing::RouteSet.send(:prepend, RecognizePathHelper)
