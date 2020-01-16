# frozen_string_literal: true

class Submission < Edge
  enhance LinkedRails::Enhancements::Creatable

  property :session_id, :string, NS::ARGU[:sessionID]

  parentable :survey

  alias_attribute :display_name, :session_id
end
