# frozen_string_literal: true

# @todo remove after migration
class Decision < Edge
  enhance Loggable
  enhance MarkAsImportant
end
