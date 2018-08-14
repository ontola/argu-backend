# frozen_string_literal: true

class ShortnameSerializer < RecordSerializer
  has_one :owner, predicate: NS::ARGU[:shortnameable]
end
