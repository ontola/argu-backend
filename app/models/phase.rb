class Phase < ActiveRecord::Base
  include ArguBase, Placeable

  belongs_to :forum
  belongs_to :project, inverse_of: :phases
  belongs_to :creator, class_name: 'Profile'
  belongs_to :publisher, class_name: 'User'

  validates :forum, presence: true
  validates :project, presence: true
  validates :creator, presence: true

  # For Rails 5 attributes
  # attribute :name, :string
  # attribute :description, :text
  # attribute :integer, :position
  # attribute :start_date, :datetime
  # attribute :end_date, :datetime
  alias_attribute :display_name, :name


  counter_culture :project

end
