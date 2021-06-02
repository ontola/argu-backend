# frozen_string_literal: true

class BannerDismissalActionList < EdgeActionList
  has_collection_create_action(
    label: -> { '' },
    submit_label: -> { resource.parent.dismiss_button }
  )
end
