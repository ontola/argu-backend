# frozen_string_literal: true

class BannerManagement < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Menuable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Tableable
  enhance LinkedRails::Enhancements::Destroyable
  enhance ActivePublishable
  enhance Dismissable

  with_columns default: [
    NS::SCHEMA[:text],
    NS::ONTOLA[:audience],
    NS::ONTOLA[:publishAction],
    NS::ARGU[:expiresAt],
    NS::ONTOLA[:updateAction],
    NS::ONTOLA[:destroyAction]
  ]

  property :description, :text, NS::SCHEMA[:text]
  property :audience, :integer, NS::ONTOLA[:audience], default: 0, enum: {everyone: 0, guests: 1, users: 2}
  property :dismiss_button, :string, NS::ONTOLA[:dismissButton]

  validates :description, length: {minimum: 1, maximum: MAXIMUM_DESCRIPTION_LENGTH}

  parentable :page

  def iri_template_name
    :banners_iri
  end

  def parent_collections_for(parent, user_context)
    parent
      .collections
      .select { |collection| [Banner, BannerManagement].include?(collection[:options][:association_class]) }
      .map { |collection| parent.collection_for(collection[:name], user_context: user_context) }
  end

  class << self
    def default_collection_display
      :table
    end

    def form_class
      BannerForm
    end
  end
end
