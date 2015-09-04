
namespace :argu do

  task :clean_tenants do
    ActiveRecord::Base.establish_connection
    tenants = Shortname.where(owner_type: 'Forum').pluck :shortname

    easy_models = [AccessToken, Argument, Comment, Group, GroupResponse, Membership, Motion,
                   Question, Tagging, Vote, Tag, Follow, GroupMembership, QuestionAnswer, Rule]

    ActiveRecord::Base.transaction do
      sql = ''
      tenants.each do |t_name|
        easy_models.each do |model|
          sql << "TRUNCATE TABLE #{t_name}.#{model.model_name.collection} RESTART IDENTITY; "
        end
      end
      Rails.logger.info(sql)
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  task :migrate_tenants do
    ActiveRecord::Base.establish_connection
    tenants = Shortname.where(owner_type: 'Forum').pluck :shortname

    def quoted_column_names(klass)
      "#{klass.column_names.map { |i| "\"#{i}\""  }.join(', ')} "
    end

    easy_models = [Argument, Group, GroupResponse, Membership, Motion,
                   Question, Tagging, Vote]
    custom_models = [AccessToken]

    hard_models = {
        Comment => Proc.new do |model, t_name, t_id|
          "insert into #{t_name}.#{model.model_name.collection} (#{quoted_column_names(model)}) " +
              "select #{quoted_column_names(model)} " +
              "from public.#{model.model_name.collection} " +
              "where parent_id IN (#{Argument.where(forum_id: t_id).pluck(:id)}); "
        end,
        GroupMembership => Proc.new do |model, t_name, t_id|
          "insert into #{t_name}.#{model.model_name.collection} (#{quoted_column_names(model)}) " +
              "select #{quoted_column_names(model)} " +
              "from public.#{model.model_name.collection} " +
              "where group_id IN (#{Group.where(forum_id: t_id).pluck(:id)}); "
        end
    }
    # Tag, Follow, , QuestionAnswer, Rule

    ActiveRecord::Base.transaction do
      sql = ''
      tenants.each do |t_name|
        t_id = Forum.find_via_shortname(t_name).id

        easy_models.each do |model|
          sql << "insert into #{t_name}.#{model.model_name.collection} (#{quoted_column_names(model)}) " +
              "select #{quoted_column_names(model)} " +
              "from public.#{model.model_name.collection} " +
              "where forum_id = #{t_id}; "
        end

        hard_models.each { |k, v| v.call(k, t_name, t_id) }
      end
      Rails.logger.info(sql)
      ActiveRecord::Base.connection.execute(sql)
      #raise 'REVERT ALL THE THINGS!'
    end
  end
end
