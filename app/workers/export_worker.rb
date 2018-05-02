# frozen_string_literal: true

require 'zip'

class ExportWorker
  include Sidekiq::Worker

  attr_accessor :export

  def perform(export_id)
    self.export = Export.find_by(id: export_id)
    return if export.blank?
    export.processing!
    generate_zip
    export.done!
  rescue StandardError => e
    Bugsnag.notify(e)
    export.failed!
  ensure
    DataEvent.publish(export) if export.present?
  end

  private

  def add_json(zip)
    json = data.map { |type, records| [type.tableize, JSON.parse(serializer_for(records, :attributes).to_json)] }
    zip.get_output_stream('data.json') { |f| f.write Hash[json].to_json }
  end

  def add_triple_formats(zip)
    serializer = serializer_for(data.values, :rdf)
    %i[n3 ntriples jsonld rdf].map do |format|
      zip.get_output_stream("data.#{format}") { |f| f.write serializer.adapter.dump(RDF::Format.for(format).to_sym) }
    end
  end

  def add_xls(zip)
    book = Spreadsheet::Workbook.new
    data.each do |type, records|
      sheet = book.create_worksheet(name: I18n.t("#{type.tableize}.plural"))
      serializer_for(records, :attributes).as_json.each_with_index do |record, index|
        sheet.row(0).replace(record.keys.map { |key| key.to_s.gsub('Collection', 'Count') }) if index.zero?
        sheet.row(index + 1).replace(record.values.map { |value| format_value_xls(value) })
      end
    end
    zip.get_output_stream('data.xls') { |f| book.write(f) }
  end

  def data
    @data ||=
      export
        .edge
        .self_and_descendants
        .includes(:activities, :publications, :parent, owner: {edge: :parent})
        .flat_map(&method(:relations))
        .group_by { |m| m.class.name }
  end

  def format_value_xls(value)
    case value
    when Array
      value.map { |v| format_value_xls(v) }.join(', ')
    when Hash
      if value[:type] == NS::ARGU[:Collection]
        value[:totalCount]
      elsif value[:iri].present?
        Spreadsheet::Link.new(value[:iri].to_s)
      end
    when RDF::URI
      Spreadsheet::Link.new(value.to_s)
    else
      value
    end
  end

  def generate_zip
    filename = Rails.root.join('tmp', 'argu-data-export.zip')
    Zip::File.open(filename, Zip::File::CREATE) do |zip|
      add_xls(zip)
      add_json(zip)
      add_triple_formats(zip)
    end
    export.update!(zip: File.open(filename))
    File.delete(filename)
  end

  def relations(edge)
    [
      edge.owner,
      edge.owner.try(:default_profile_photo),
      edge.owner.try(:media_objects).try(:to_a),
      edge.owner.try(:placements).try(:to_a)
    ].flatten.compact
  end

  def scope
    @scope ||= UserContext.new(user: export.user, doorkeeper_scopes: %w[export])
  end

  def serializer_for(records, adapter)
    ActiveModelSerializers::SerializableResource.new(records, adapter: adapter, scope: scope)
  end
end
