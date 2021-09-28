# frozen_string_literal: true

class CustomFormFieldSerializer < EdgeSerializer
  attribute :sh_path, predicate: NS.sh.path
end
