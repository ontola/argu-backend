class AddUrlToWidgets < ActiveRecord::Migration[5.2]
  include UriTemplateHelper

  def up
    CreativeWork.new_motion.includes(:parent, :root).find_each do |creative_work|
      ActsAsTenant.with_tenant(creative_work.root) do
        creative_work.update(url_path: new_iri_path(creative_work.parent, :motions))
      end
    end
    CreativeWork.new_question.includes(:parent, :root).find_each do |creative_work|
      ActsAsTenant.with_tenant(creative_work.root) do
        creative_work.update(url_path: new_iri_path(creative_work.parent, :questions))
      end
    end
    CreativeWork.new_topic.includes(:parent, :root).find_each do |creative_work|
      ActsAsTenant.with_tenant(creative_work.root) do
        creative_work.update(url_path: new_iri_path(creative_work.parent, :topics))
      end
    end
  end
end
