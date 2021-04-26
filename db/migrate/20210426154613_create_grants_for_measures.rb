class CreateGrantsForMeasures < ActiveRecord::Migration[6.0]
  def change
    Measure.find_each do |measure|
      measure.send(:create_default_grant)
    end
  end
end
