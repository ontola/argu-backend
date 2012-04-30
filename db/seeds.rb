# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create(username: 'thom', email:'thom@wthex.com', password:'foobar', password_confirmation:'foobar')
sa = Statement.create(title:'Free education', content: 'Education should be free')
sb = Statement.create(title:'Statement2', content: 'Another statement')

a = Argument.create(title:'Some arg', content:'Very descriptive', argtype:'ARGUMENT_TYPE_SCIENTIFIC')
aa = Argument.create(title:'Some argA', content:'Description A', argtype:'ARGUMENT_TYPE_AXIOMATIC')
ao = Argument.create(title:'Some argO', content:'Description O', argtype:'ARGUMENT_TYPE_OTHER')

sa = Statementargument.create(argument_id:a.id, statement_id:sa.id, pro: true)
sb = Statementargument.create(argument_id:ao.id, statement_id:sa.id, pro: false)
sc = Statementargument.create(argument_id:aa.id, statement_id:sb.id, pro: false)
sd = Statementargument.create(argument_id:ao.id, statement_id:sb.id, pro: true)
