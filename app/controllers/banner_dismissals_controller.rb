# frozen_string_literal: true

class BannerDismissalsController < EdgeableController
  private

  def active_response_success_message; end

  def create_meta
    super + [
      [
        parent_resource.iri,
        NS::ONTOLA[:dismissedAt],
        Time.current,
        delta_iri(:replace)
      ]
    ]
  end

  def permit_params
    {}
  end
end
