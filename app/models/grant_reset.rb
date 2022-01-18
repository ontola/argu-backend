# frozen_string_literal: true

class GrantReset < ApplicationRecord
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Updatable

  belongs_to :edge, inverse_of: :grant_resets, primary_key: :uuid
  alias edgeable_record edge

  enum action_name: {
    create: 1,
    show: 2,
    update: 3,
    destroy: 4,
    trash: 5
  }, _prefix: true
  enum resource_type: {
    Forum: 1,
    BlogPost: 2,
    Question: 3,
    Motion: 4,
    ProArgument: 5,
    ConArgument: 6,
    Comment: 7,
    Vote: 8
  }, _prefix: true

  collection_options(
    display: :table
  )
  with_columns default: [
    NS.argu[:edge],
    NS.argu[:resourceType],
    NS.argu[:actionName],
    NS.ontola[:destroyAction]
  ]

  def added_delta
    super + [
      [NS.sp.Variable, RDF.type, NS.argu['GrantTree::PermissionGroup'], NS.ontola[:invalidate]]
    ]
  end

  def display_name; end

  def parent_collections(user_context)
    [edge, edge.grant_tree_node(user_context)].flatten.map do |parent|
      parent_collections_for(parent, user_context)
    end.flatten + [edge.grant_tree_node(user_context).permission_group_collection]
  end

  class << self
    def attributes_for_new(opts)
      parent = opts[:parent].is_a?(GrantTree::Node) ? opts[:parent].edgeable_record : opts[:parent]

      {
        edge: parent
      }
    end
  end
end
