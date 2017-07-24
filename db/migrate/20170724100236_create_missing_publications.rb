class CreateMissingPublications < ActiveRecord::Migration[5.0]
  def change
    [Motion, Question].each do |klass|
      scope = klass
                .joins(:edge)
                .joins('LEFT JOIN publications ON publications.publishable_id = edges.id')
                .where('publications.id IS NULL')
      pre_publication_count = Publication.count
      count = scope.count
      scope.find_each do |record|
        record
          .edge
          .create_argu_publication(
            published_at: record.created_at,
            creator: record.creator,
            publisher: record.publisher
          )
      end

      raise unless Publication.count == pre_publication_count + count
    end
  end
end
