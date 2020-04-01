class ConvertActionWidgets < ActiveRecord::Migration[6.0]
  def change
    %i[new_motion new_question new_topic].each do |widget_type|
      Widget
        .where(widget_type: widget_type)
        .find_each do |widget|
        widget.update(resource_iri: [["#{widget.resource_iri.first.first}#EntryPoint", nil]])
        end
      end
  end
end
