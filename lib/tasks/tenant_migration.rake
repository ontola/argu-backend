
namespace :argu do
  include Argu::TenantUtilities::ModelTypes
  include Argu::TenantUtilities::SQLMethods

  task :clean_tenants do
    ActiveRecord::Base.establish_connection
    tenants = Shortname.where(owner_type: 'Forum').pluck :shortname

    models = [AccessToken, Argument, Comment, Group, GroupResponse, Membership, Motion,
                   Question, Tagging, Vote, Tag, Follow, GroupMembership, QuestionAnswer, Rule]

    ActiveRecord::Base.transaction do
      sql = ''
      tenants.each do |t_name|
        models.each do |model|
          sql << "TRUNCATE TABLE #{t_name}.#{model.model_name.collection} RESTART IDENTITY; "
        end
      end
      Rails.logger.info(sql)
      ActiveRecord::Base.connection.execute(sql)
    end
  end

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

        Forum.find_each do |f|
          Notification.where(activity_id: Activity.where(forum_id: f.id)).update_all forum_id: f.id
        end
      end
      Rails.logger.info(sql)
      ActiveRecord::Base.connection.execute(sql)
      #raise 'REVERT ALL THE THINGS!'
    end
  end

  def collect_follow_ids(t_id)
    ids = []

    EASY_MODELS.each do |model|
      ids.concat Follow.where(
                     followable_type: model.model_name.name,
                     followable_id: model.where(forum_id: t_id)
                                        .select(:id)
                 ).pluck(:followable_id)
    end

    ids.concat Follow.where(followable_id:
                                Comment.where(commentable_id:
                                                  Argument.where(forum_id: t_id)
                                                      .select(:id)
                                ).select(:id)
               ).pluck(:id)
  end
end
