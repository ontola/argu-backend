# frozen_string_literal: true

class GrantedGroups < LinkedRails::Sequence
  include LinkedRails::Model

  def iri
    id
  end

  class << self
    def iri
      RDF[:Seq]
    end

    def requested_resource(opts, user_context)
      return unless collection_action?(opts)

      parent = parent_from_params(opts[:params], user_context).persisted_edge

      GrantedGroups.new(
        user_context.grant_tree.granted_groups(parent),
        id: RDF::URI(opts[:iri]),
        parent: parent,
        scope: false
      )
    end
  end
end
