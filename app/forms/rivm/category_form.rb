# frozen_string_literal: true

class CategoryForm < ApplicationForm
  fields(
    %i[
      display_name
      description
    ]
  )
end
