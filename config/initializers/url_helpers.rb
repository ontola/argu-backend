# frozen_string_literal: true

# @todo no longer needed if old frondend is ditched

module RDFIRIHelper
  def url_for(obj)
    obj = obj.iri.to_s if obj.respond_to?(:iri)
    super
  end
end

ActionView::RoutingUrlFor.send(:prepend, RDFIRIHelper)
