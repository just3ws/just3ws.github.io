# frozen_string_literal: true

require 'spec_helper'
require_relative '../../_plugins/markdown_export'

RSpec.describe Jekyll::MarkdownExportGenerator do
  let(:site) { double('Jekyll::Site', config: { 'author' => { 'name' => 'Mike Hall' }, 'description' => 'Staff Engineer' }, dest: Dir.mktmpdir, pages: []) }

  it 'instantiates generator safely' do
    generator = described_class.new
    expect(generator).to be_a(Jekyll::Generator)
  end
end
