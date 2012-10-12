# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
['user', 'moderator', 'admin', 'coder'].each do |role|
  Role.find_or_create_by_name(role).save
end

ua = User.create(email: 'thomvankalkeren@gmail.com', username: 'TheFletcher91', password: 'foobar', password_confirmation:'foobar' );
ub = User.create(username: 'admin', email: 'postmaster@argu.nl', password:'foobar', password_confirmation:'foobar')

ua.profile = Profile.create(name: 'Thom van Kalkeren', picture: 'http://www.wthex.com/images/coolcookie.gif', about: "I'm the coder!")
ub.profile = Profile.create(name: 'Administrator')

ua.roles << Role.find_by_name('coder')
ub.roles << Role.find_by_name('admin')

sa = Statement.create(title:'Free education', content: 'Education should be free')
sb = Statement.create(title:'Statement2', content: 'Another statement')

a = Argument.create(title:'Some arg', content:'Very descriptive', argtype:'0')
aa = Argument.create(title:'Some argA', content:'Description A', argtype:'1')
ao = Argument.create(title:'Some argO', content:'Description O', argtype:'2')

sa = Statementargument.create(argument_id:a.id, statement_id:sa.id, pro: true)
sb = Statementargument.create(argument_id:ao.id, statement_id:sa.id, pro: false)
sc = Statementargument.create(argument_id:aa.id, statement_id:sb.id, pro: false)
sd = Statementargument.create(argument_id:ao.id, statement_id:sb.id, pro: true)
