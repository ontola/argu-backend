$('#shr<%= @argument.id %>')
.replaceWith('<%= escape_javascript(render(partial: "votes/shr", locals: {argument: @argument}))%>')