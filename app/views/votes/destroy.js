$('#votebtn<%= @argument.id %>')
  .fadeOut()
  .replaceWith('<%= escape_javascript(render(partial: "arguments/shr", locals: {argument: @argument}))%>')
  .hide()
  .fadeIn();