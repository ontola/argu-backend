# frozen_string_literal: true

class Banner < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Menuable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Tableable
  enhance LinkedRails::Enhancements::Destroyable
  enhance ActivePublishable
  enhance Dismissable

  property :description, :text, NS::SCHEMA[:text]
  property :audience, :integer, NS::ONTOLA[:audience], default: 0, enum: {everyone: 0, guests: 1, users: 2}
  property :dismiss_button, :string, NS::ONTOLA[:dismissButton]

  with_columns default: [
    NS::SCHEMA[:text],
    NS::ONTOLA[:audience],
    NS::ONTOLA[:publishAction],
    NS::ARGU[:expiresAt],
    NS::ONTOLA[:updateAction],
    NS::ONTOLA[:destroyAction]
  ]

  validates :description, length: {minimum: 1, maximum: MAXIMUM_DESCRIPTION_LENGTH}

  parentable :page

  def display_name; end

  def parent_collections_for(parent, user_context)
    parent
      .collections
      .select { |collection| [Banner, ActiveBanner].include?(collection[:options][:association_class]) }
      .map { |collection| parent.collection_for(collection[:name], user_context: user_context) }
  end

  class << self
    def iri_namespace
      NS::ONTOLA
    end
  end
end
