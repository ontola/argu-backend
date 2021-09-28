# frozen_string_literal: true

class Vocabulary < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance Trashable
  enhance LinkedRails::Enhancements::Updatable
  enhance CoverPhotoable
  enhance Attachable
  enhance RootGrantable
  include Shortnameable
  collection_options(
    display: :table
  )

  property :system, :boolean, NS.argu[:system]
  property :display_name, :string, NS.schema.name
  property :description, :text, NS.schema.text
  property :tagged_label, :string, NS.argu[:taggedLabel]
  property :term_type, :iri, NS.argu[:termType]
  property :default_term_display,
           :integer,
           NS.argu[:defaultDisplay],
           default: 0,
           enum: {default_display: 0, grid_display: 1, table_display: 2, card_display: 3}

  with_columns default: [
    NS.schema.name,
    NS.ontola[:updateAction],
    NS.ontola[:destroyAction]
  ]
  with_collection :terms,
                  display: -> { parent.default_term_display&.to_s&.sub('_display', '') },
                  title: -> { parent.display_name }

  parentable :page

  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :display_name, presence: true, length: {maximum: 110}

  after_trash -> { shortname.update(primary: false) }

  class << self
    def terms_iri(url, **opts)
      active.find_via_shortname(url)&.term_collection(opts)&.iri
    end

    def route_key
      :vocab
    end

    def upvote_options
      active.find_via_shortname('upvoteOptions')
    end

    def vote_options
      active.find_via_shortname('voteOptions')
    end
  end
end
