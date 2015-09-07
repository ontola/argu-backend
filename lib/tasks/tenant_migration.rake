
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

  EASY_MODELS = [Argument, Group, GroupResponse, Membership, Motion,
                 Question, Tagging, Vote]
  HARD_MODELS = {
      Comment => Proc.new do |model, t_name, t_id|
        in_statement(model, t_name, t_id, :parent_id, Argument)
      end,
      GroupMembership => Proc.new do |model, t_name, t_id|
        in_statement(model, t_name, t_id, :group_id, Group)
      end,
      QuestionAnswer => Proc.new do |model, t_name, t_id|
        in_statement(model, t_name, t_id, :motion_id, Motion)
      end,
      Tag => Proc.new do |model, t_name, t_id|
        in_statement(model, t_name, t_id, :id, Tagging, :tag_id)
      end,


      Rule => Proc.new do |model, t_name, t_id|
        custom_belongs_to(model, t_name, t_id, :context_id, :context_type)
      end,
      AccessToken => Proc.new do |model, t_name, t_id|
        custom_belongs_to(model, t_name, t_id, :item_id, :item_type)
      end
  }

  task :migrate_tenants do
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.transaction do
      sql = ''
      tenants = Shortname.where(owner_type: 'Forum').pluck :shortname

      tenants.each do |t_name|
        t_id = Forum.find_via_shortname(t_name).id

        EASY_MODELS.each do |model|
          sql << migration_base_sql(model, t_name) +
              "where forum_id = #{t_id}; "
        end

        HARD_MODELS.each { |k, v| sql << v.call(k, t_name, t_id) }

        sql << in_statement!(Follow,
                             t_name,
                             t_id,
                             :id,
                             collect_follow_ids(t_id))
      end
      Rails.logger.info(sql)
      ActiveRecord::Base.connection.execute(sql)
      #raise 'REVERT ALL THE THINGS!'
    end
  end

  def collect_follow_ids(t_id)
    ids = []

    EASY_MODELS.each do |model|
      ids.concat Follow.where(followable_type: model.model_name.name,
                   followable_id: model.where(forum_id: t_id).select(:id))
              .pluck(:followable_id)
    end

    ids.concat Follow
               .where(followable_id: Comment
                                         .where(commentable_id: Argument
                                                                    .where(forum_id: t_id)
                                                                    .select(:id))
                                         .select(:id))
               .pluck(:id)
  end

  def custom_belongs_to(model, t_name, t_id, foreign_id_column, foreign_type_column)
    migration_base_sql(model, t_name) +
        "where #{foreign_id_column} = #{t_id} AND #{foreign_type_column} = 'Forum'; "
  end

  def in_statement(model, t_name, t_id, foreign_column, other_class, pluck_column = :id)
    in_statement!(model, t_name, t_id, foreign_column, other_class.where(forum_id: t_id).pluck(pluck_column))
  end

  def in_statement!(model, t_name, t_id, foreign_column, id_array)
    if id_array.length > 0
      migration_base_sql(model, t_name) +
        "where #{foreign_column} IN (#{id_array.join(', ')}); "
    else
      ''
    end
  end

  def migration_base_sql(model, t_name)
    "insert into #{t_name}.#{model.model_name.collection} (#{quoted_column_names(model)}) " +
        "select #{quoted_column_names(model)} " +
        "from public.#{model.model_name.collection} "
  end

  def quoted_column_names(klass)
    "#{klass.column_names.map { |i| "\"#{i}\""  }.join(', ')} "
  end
end
