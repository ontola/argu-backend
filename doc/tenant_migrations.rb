

ActiveRecord::Base.establish_connection

easy_models = [Argument, Group, GroupResponse, Membership, Motion,
               Question, Tagging, Vote]
custom_models = [AccessToken]
hard_models = {
    Comment => Proc.new do |model, t_name, t_id|
      "insert into #{t_name}.#{model.model_name.collection} (#{quoted_column_names(model)})" +
      "select #{quoted_column_names(model)}" +
      "from public.#{t_name}" +
      "where parent_id IN (#{Argument.where(forum_id: t_id).pluck(:id)});"
    end,
    GroupMembership => Proc.new do |model, t_name, t_id|
      "insert into #{t_name}.#{model.model_name.collection} (#{quoted_column_names(model)})" +
      "select #{quoted_column_names(model)}" +
      "from public.#{t_name}" +
      "where group_id IN (#{Group.where(forum_id: t_id).pluck(:id)});"
    end
}
# Tag, Follow, , QuestionAnswer, Rule

tenants = Shortname.where(owner_type: 'Forum').pluck :shortname

def quoted_column_names(klass)
  klass.column_names.reduce { |a, i| a << "\"#{i}\""  }
end

ActiveRecord::Base.transaction do
  sql = ''
  tenants.each do |t_name|
    t_id = Forum.find_via_shortname(t_name).id

    easy_models.each do |model|
      sql << "insert into #{t_name}.#{model.model_name.collection} (#{quoted_column_names(model)})" +
             "select #{quoted_column_names(model)}" +
             "from public.#{t_name}" +
             "where forum_id = #{t_id};"
    end

    hard_models.each { |k, v| v.call(k, t_name, t_id) }
  end
  Rails.logger.debug(sql)
  ActiveRecord::Base.connection.execute(sql)
  raise 'REVERT ALL THE THINGS!'
end
