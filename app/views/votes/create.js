
$('<%= @model.class_name == "motions" ? ".motion-shr" : "#votebtn#{@model.id}"%>').replaceWith('<%= escape_javascript(render(partial: "#{@model.class_name}/shr", locals: {model: @model, vote: @vote}))%>');
