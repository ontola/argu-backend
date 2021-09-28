class ConvertVoteOptions < ActiveRecord::Migration[6.0]
  def change
    Page.find_each do |page|
      ActsAsTenant.with_tenant(page) do
        unless Vocabulary.vote_options.present?
          puts "Skipping #{page.iri}: Vocabulary.vote_options not present"
          next
        end

        {no: 0, yes: 1, other: 2}.each do |key, value|
          Property
            .joins(edge: :parent)
            .where(
              predicate: NS.schema.option.to_s,
              integer: value
            )
            .update_all(linked_edge_id: Vocabulary.vote_options.active_terms.find_by(exact_match: NS.argu[key]).uuid)

          Argu::Redis.keys("temporary.*#{page.uuid}.vote*").each do |key|
            value = JSON.parse(Argu::Redis.get(key))
            option = value.delete('option')
            value['option_id'] = Vocabulary.vote_options.active_terms.find_by(exact_match: NS.argu[option])&.uuid if option
            Argu::Redis.set(key, value.to_json)
          end
        end
      end
    end

    Vote.fix_counts
  end
end
