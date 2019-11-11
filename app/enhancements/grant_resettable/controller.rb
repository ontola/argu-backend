# frozen_string_literal: true

module GrantResettable
  module Controller
    extend ActiveSupport::Concern

    private

    def update_meta # rubocop:disable Metrics/AbcSize
      meta = super
      if current_resource.previously_changed_relations.include?('grant_resets')
        potential = current_resource.actions_iri(:potentialAction)
        favorite = current_resource.actions_iri(:favoriteAction)
        meta.concat(
          [
            [current_resource.iri, NS::SCHEMA.potentialAction, potential, delta_iri(:replace)],
            [current_resource.iri, NS::ONTOLA[:favoriteAction], favorite, delta_iri(:replace)],
            [potential, NS::SP[:Variable], NS::SP[:Variable], delta_iri(:invalidate)],
            [favorite, NS::SP[:Variable], NS::SP[:Variable], delta_iri(:invalidate)]
          ]
        )
      end
      meta
    end
  end
end
