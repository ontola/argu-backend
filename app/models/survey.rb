# frozen_string_literal: true

class Survey < Discussion
  TYPEFORM_MANAGE_TEMPLATE = URITemplate.new('https://admin.typeform.com/form/{typeform_id}/create')
  TYPEFORM_TEMPLATE = %r{\Ahttps:\/\/(\w*).typeform.com\/to\/(\w*)\z}
  include Edgeable::Content

  property :external_iri, :string, NS::ARGU[:externalIRI]

  with_collection :submissions

  validates :display_name, presence: true, length: {minimum: 4, maximum: 75}
  validates :description, length: {maximum: MAXIMUM_DESCRIPTION_LENGTH}
  validates :external_iri, format: {with: TYPEFORM_TEMPLATE}

  def manage_iri
    TYPEFORM_MANAGE_TEMPLATE.expand(typeform_id: typeform_id)
  end

  def submission_for(user)
    if user.guest?
      submissions.find_by(session_id: user.id)
    else
      submissions.find_by(publisher: user)
    end
  end

  def typeform_account
    external_iri.match(Survey::TYPEFORM_TEMPLATE)[1]
  end

  def typeform_id
    external_iri.match(Survey::TYPEFORM_TEMPLATE)[2]
  end
end
