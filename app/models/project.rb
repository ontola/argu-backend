# frozen_string_literal: true

class Project < Edge
  belongs_to :creator, class_name: 'Profile', inverse_of: :projects
  belongs_to :publisher, class_name: 'User'
end
