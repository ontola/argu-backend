# frozen_string_literal: true

class CustomFormField < Edge
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Updatable
  enhance CoverPhotoable
  enhance Trashable
  enhance Orderable

  term_property :form_field_type_id, NS.argu[:formFieldType], association: :form_field_type
  property :display_name, :string, NS.schema.name
  property :description, :text, NS.schema.text
  property :helper_text, :text, NS.ontola[:helperText]
  property :default_value, :string, NS.form[:defaultValue]
  property :datatype, :iri, NS.sh.datatype
  property :max_count, :integer, NS.sh.maxCount
  property :max_count_prop, :iri, NS.ontola[:maxCount]
  property :min_count, :integer, NS.sh.minCount
  property :min_count_prop, :iri, NS.ontola[:minCount]
  property :max_inclusive, :integer, NS.sh.maxInclusive
  property :max_inclusive_prop, :iri, NS.ontola[:maxInclusive]
  property :max_inclusive_label, :string, NS.ontola[:maxInclusiveLabel]
  property :min_inclusive, :integer, NS.sh.minInclusive
  property :min_inclusive_prop, :iri, NS.ontola[:minInclusive]
  property :min_inclusive_label, :string, NS.ontola[:minInclusiveLabel]
  property :max_length, :integer, NS.sh.maxLength
  property :max_length_prop, :iri, NS.ontola[:maxLength]
  property :min_length, :integer, NS.sh.minLength
  property :min_length_prop, :iri, NS.ontola[:minLength]
  property :pattern, :string, NS.sh.pattern
  property :predicate, :iri, NS.argu[:predicate]
  property :options_vocab_id,
           :linked_edge_id,
           NS.argu[:optionsVocab],
           association_class: 'Vocabulary'
  accepts_nested_attributes_for :options_vocab

  validates :form_field_type, presence: true
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :helper_text, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}

  parentable :custom_form
  attribute :rdf_type

  with_columns default: [
    NS.argu[:order],
    NS.schema.name,
    NS.argu[:formFieldType],
    NS.ontola[:updateAction],
    NS.ontola[:destroyAction]
  ]

  def rdf_type
    form_field_type&.exact_match
  end

  def required
    min_count&.positive?
  end

  def required=(value)
    self.min_count = value ? 1 : 0
  end

  def sh_path
    predicate || iri
  end

  def swipe_tool?
    parent.parent.is_a?(SwipeTool)
  end

  class << self
    def attributes_for_new(opts)
      super.merge(max_count: 1)
    end

    def swipe_type
      Vocabulary.find_via_shortname(:formFields).terms.find_by(exact_match: NS.form[:SwipeInput])
    end

    def build_new(parent: nil, user_context: nil)
      resource = super
      resource.form_field_type = swipe_type if resource.swipe_tool?
      resource.build_options_vocab(
        creator: user_context&.profile,
        display_name: I18n.t('sh.in.label'),
        publisher: user_context&.user
      )
      resource
    end
  end
end
