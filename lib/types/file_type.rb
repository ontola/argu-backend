# frozen_string_literal: true

class FileType < ActiveRecord::Type::Value
  def type
    :file
  end
end
