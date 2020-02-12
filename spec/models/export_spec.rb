# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exports', type: :model do
  define_spec_objects

  context 'Page' do
    subject { Export.create(edge: freetown, user: User.first) }

    let(:tmp_path) { Rails.root.join('tmp/file.tmp') }

    it 'exports data' do
      subject
      ExportWorker.drain
      expect(subject.reload.status).to eq('done')
      File.delete(tmp_path) if File.exist?(tmp_path)
      Zip::File.open(subject.zip.path).detect { |f| f.name == 'data.n3' }.extract(tmp_path)
      File.foreach(tmp_path) { |line| expect(line).not_to(match(/@.+\./)) }
      expect(File.foreach(tmp_path)).to(be_any { |line| line.include?('anonymous') })
      File.delete(tmp_path)
    end
  end
end
