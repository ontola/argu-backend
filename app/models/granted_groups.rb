# frozen_string_literal: true

class GrantedGroups < LinkedRails::Sequence
  include LinkedRails::Model
  include URITemplateHelper

  def iri_opts
    {
      parent_iri: split_iri_segments(parent&.root_relative_iri)
    }
  end

  class << self
    def iri
      RDF[:Seq]
    end

    def iri_template
      @iri_template ||= LinkedRails::URITemplate.new("{/parent_iri*}/#{route_key}")
    end

    def requested_resource(opts, user_context)
      return unless collection_action?(opts)

      parent = parent_from_params(opts[:params], user_context)&.persisted_edge
      return if parent.blank?

      GrantedGroups.new(
        user_context.grant_tree.granted_groups(parent),
        parent: parent,
        scope: false
      )
    end

    def route_key
      :granted
    end
  end
end
