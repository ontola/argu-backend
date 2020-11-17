# frozen_string_literal: true

class Submission < Edge
  include DeltaHelper

  enhance LinkedRails::Enhancements::Creatable

  property :session_id, :string, NS::ARGU[:sessionID]

  parentable :survey

  alias_attribute :display_name, :session_id

  def added_delta
    [
      invalidate_resource_delta(parent.action(:create_submission))
    ]
  end
end
