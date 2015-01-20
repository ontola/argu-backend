
$('<%= @model.class_name == "motions" ? ".btns-opinion" : "#votebtn#{@model.id}"%>').replaceWith('<%= escape_javascript(render(partial: "#{@model.class_name}/shr", locals: {model: @model, vote: @vote}))%>');
