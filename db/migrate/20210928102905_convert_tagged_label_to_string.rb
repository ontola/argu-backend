class ConvertTaggedLabelToString < ActiveRecord::Migration[6.1]
  def change
    Property.where(predicate: NS.argu[:taggedLabel]).update_all('string = text')
  end
end
