# frozen_string_literal: true

class Survey < Discussion
  TYPEFORM_MANAGE_TEMPLATE = URITemplate.new('https://admin.typeform.com/form/{typeform_id}/create')
  TYPEFORM_TEMPLATE = %r{\Ahttps:\/\/(\w*).typeform.com\/to\/(\w*)\z}.freeze

  enhance Settingable

  include Edgeable::Content

  property :external_iri, :string, NS.argu[:externalIRI]
  property :reward, :integer, NS.argu[:reward], default: 0
  parentable :container_node, :page, :phase
  with_collection :submissions

  validates :display_name, presence: true, length: {minimum: 4, maximum: 75}
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :external_iri, format: {allow_nil: true, with: TYPEFORM_TEMPLATE}

  def added_delta
    super + [
      invalidate_resource_delta(menu(:settings))
    ]
  end

  def currency
    'EUR'
  end

  def manage_iri
    TYPEFORM_MANAGE_TEMPLATE.expand(typeform_id: typeform_id) if external_iri
  end

  def submission_for(user_context)
    return nil if user_context.nil?

    if user_context.guest?
      submissions.reorder(created_at: :desc).find_by(session_id: user_context.session_id)
    else
      submissions.reorder(created_at: :desc).find_by(publisher: user_context.user)
    end
  end

  def typeform_account
    external_iri&.match(Survey::TYPEFORM_TEMPLATE).try(:[], 1)
  end

  def typeform_id
    external_iri&.match(Survey::TYPEFORM_TEMPLATE).try(:[], 2)
  end
end
