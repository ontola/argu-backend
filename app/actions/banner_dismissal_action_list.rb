# frozen_string_literal: true

class BannerDismissalActionList < EdgeActionList
  has_action(
    :create,
    create_options.merge(
      label: -> { '' },
      submit_label: -> { resource.parent.dismiss_button }
    )
  )
end
