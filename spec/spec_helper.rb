# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("..", __dir__))

require "erb"
require "tmpdir"
require "fileutils"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def render_template(path, locals = {})
  template = ERB.new(File.read(path), trim_mode: "-")
  context = Object.new
  locals.each do |name, value|
    context.define_singleton_method(name) { value }
  end
  template.result(context.instance_eval { binding })
end
