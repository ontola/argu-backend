# frozen_string_literal: true

class CustomActionPolicy < EdgePolicy
  def permitted_attribute_names
    %i[
      raw_label label_translation raw_description description_translation raw_submit_label submit_label_translation href
    ]
  end
end
