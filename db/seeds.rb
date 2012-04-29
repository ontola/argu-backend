# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create(username: 'thom', email:'thom@wthex.com', password:'foobar', password_confirmation:'foobar')
s = Statement.create(title:'Free education', content: 'Education should be free')
a = Argument.create(title:'Some arg', content:'Very descriptive', argtype:'ARGUMENT_TYPE_SCIENTIFIC')
sa = Statementargument.create(argument_id:a.id, statement_id:s.id, pro: true)