# frozen_string_literal: true

class SurveyPolicy < EdgePolicy
  permit_attributes %i[external_iri display_name description]
  permit_attributes %i[pinned], grant_sets: %i[moderator administrator]
  permit_attributes %i[form_type coupon_required], staff: true
  permit_nested_attributes %i[action_body], staff: true

  def permitted_tabs
    tabs = %i[participate submission]
    if update?
      tabs.push(:coupon_batches) if record.coupon_required?
      tabs.push(:form) if record.action_body
      tabs.push(:typeform) if record.external_iri
      tabs.push(:submissions)
    end
    tabs
  end
end
