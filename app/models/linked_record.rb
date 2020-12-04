# frozen_string_literal: true

class LinkedRecord < Edge
  enhance Commentable
  include SerializationHelper

  property :external_iri, :string, NS::SCHEMA[:name]
  property :rdf_type, :string, NS::SCHEMA[:name]

  def anonymous_iri?
    false
  end

  def hnd_json
    same_as = external_iri.sub('openbesluitvorming', 'openraadsinformatie')
    "[\"#{external_iri}\",\"http://www.w3.org/2002/07/owl#sameAs\",\"#{iri}\","\
      "\"http://www.w3.org/1999/02/22-rdf-syntax-ns#namedNode\",\"\",\"\"]\n"\
    "[\"#{external_iri}\",\"http://www.w3.org/2002/07/owl#sameAs\",\"#{same_as}\","\
      "\"http://www.w3.org/1999/02/22-rdf-syntax-ns#namedNode\",\"\",\"\"]\n"\
    "[\"#{external_iri}\",\"http://schema.org/comment\",\"#{iri}/c\","\
      "\"http://www.w3.org/1999/02/22-rdf-syntax-ns#namedNode\",\"\",\"\"]\n" +
      serializable_resource(self, []).dump(:hndjson)
  end

  def iri_opts
    base_encoded_iri = Base64.encode64(external_iri).gsub('=', '')
    {id: base_encoded_iri.gsub("\n", '')}
  end

  def display_name; end

  class << self
    def find_or_initialize_by_iri(iri)
      LinkedRecord.find_or_initialize_by(
        external_iri: iri,
        parent: ActsAsTenant.current_tenant,
        creator: Profile.community,
        publisher: User.community
      )
    end
  end
end
