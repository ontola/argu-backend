module Argu
  module TenantUtilities

    module ModelTypes
      EASY_MODELS = [Question, Motion, Argument, Group,
                     GroupResponse, Tagging, Vote]
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
    end
  end
end
