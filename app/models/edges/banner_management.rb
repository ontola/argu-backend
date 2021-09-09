# frozen_string_literal: true

class BannerManagement < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance ActivePublishable
  enhance Dismissable

  with_columns default: [
    NS.schema.text,
    NS.ontola[:audience],
    NS.ontola[:publishAction],
    NS.argu[:expiresAt],
    NS.ontola[:updateAction],
    NS.ontola[:destroyAction]
  ]

  property :description, :text, NS.schema.text
  property :audience, :integer, NS.ontola[:audience], default: 0, enum: {everyone: 0, guests: 1, users: 2}
  property :dismiss_button, :string, NS.ontola[:dismissButton]

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
