class CreatePublicationsForUnpublishedItems < ActiveRecord::Migration[5.0]
  def up
    [BlogPost, Decision, Project].each do |klass|
      klass.left_outer_joins(:publications).where(publications: { id: nil }).find_each do |record|
        if record.argu_publication.nil?
          record.create_argu_publication(creator: record.creator, publisher: record.publisher)
        end
      end
    end
  end
end
