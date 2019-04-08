# frozen_string_literal: true

class DatasetPolicy < EdgePolicy
  def permitted_attribute_names
    attributes = super
    attributes.concat %i[
      display_name description identifier issued modified language contact_point publisher landing_page spatial temporal
      theme authority access_rights conforms_to page accrual_periodicity provenance version_info version_notes
    ]
    attributes
  end
end
