# frozen_string_literal: true

class Mock::Identity < Identity
  def email
    raise NotImplementedError
  end
end
