# frozen_string_literal: true

require 'zip'

class ExportWorker # rubocop:disable Metrics/ClassLength
  include Sidekiq::Worker

  attr_accessor :export

  def perform(export_id) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    self.export = Export.find_by(id: export_id)
    return if export.blank?

    export.processing!
    ActsAsTenant.with_tenant(export.edge.root) do
      generate_zip
    end
    export.done!
  rescue StandardError => e
    Bugsnag.notify(e)
    export.failed!
  ensure
    DataEvent.publish(export) if export.present?
  end

  private

  def add_json(zip)
    json = data.map do |type, records|
      [
        type,
        records.map { |record| json_for(record) }
      ]
    end
    zip.get_output_stream('data.json') { |f| f.write(Oj.dump(Hash[json], mode: :compat)) }
  end

  def add_triple_formats(zip)
    %i[n3 ntriples jsonld rdfxml hndjson].map do |format|
      zip.get_output_stream("data.#{format}") do |f|
        data.each do |_type, records|
          records.each do |record|
            f.write(serializer_for(record).dump(format))
          end
        end
      end
    end
  end

  def add_xls(zip) # rubocop:disable Metrics/AbcSize
    book = Spreadsheet::Workbook.new
    data.each do |type, records|
      sheet = book.create_worksheet(name: I18n.t("#{type.tableize}.plural"))
      records.each_with_index do |record, index|
        json = json_for(record)
        sheet.row(0).replace(json.keys.map { |key| key.to_s.gsub('Collection', 'Count') }) if index.zero?
        sheet.row(index + 1).replace(json.values.map { |value| format_value_xls(value) })
      end
    end
    zip.get_output_stream('data.xls') { |f| book.write(f) }
  end

  def data
    @data ||=
      export
        .edge
        .self_and_descendants
        .includes(:activities, :parent)
        .flat_map(&method(:relations))
        .group_by { |m| m.class.name }
  end

  def format_value_xls(value) # rubocop:disable Metrics/MethodLength
    case value
    when Array
      value.map { |v| format_value_xls(v) }.join(', ')
    when Hash
      if value[:type] == NS::ONTOLA[:Collection]
        value[:totalCount]
      elsif value[:iri].present?
        Spreadsheet::Link.new(value[:iri].to_s)
      end
    when RDF::URI, RDF::DynamicURI
      Spreadsheet::Link.new(value.to_s)
    else
      value
    end
  end

  def generate_zip
    filename = Rails.root.join('tmp/argu-data-export.zip')
    Zip::File.open(filename, Zip::File::CREATE) do |zip|
      add_xls(zip)
      add_json(zip)
      add_triple_formats(zip)
    end
    export.update!(zip: File.open(filename))
    File.delete(filename)
  end

  def json_for(record)
    json_api = serializer_for(record).serializable_hash
    json_api[:data][:attributes].merge(json_api[:data][:relationships])
  end

  def relations(edge)
    [
      edge,
      edge.try(:default_profile_photo),
      edge.try(:media_objects).try(:to_a),
      edge.try(:placements).try(:to_a)
    ].flatten.compact
  end

  def scope
    @scope ||= UserContext.new(user: export.user, doorkeeper_scopes: %w[export])
  end

  def serializer_for(record)
    RDF::Serializers.serializer_for(record)&.new(record, params: {scope: scope})
  end
end
