unless defined?(SPEC_HELPER_LOADED)

  GEM_ROOT     = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LIB_ROOT     = GEM_ROOT + '/lib'
  SPEC_ROOT    = GEM_ROOT + '/spec'
  TEMP_DIR     = GEM_ROOT + '/tmp'

  puts ">> GEM_ROOT     : #{GEM_ROOT}"

  $LOAD_PATH.unshift(File.dirname(__FILE__))
  $LOAD_PATH.unshift(LIB_ROOT) unless $LOAD_PATH.include?(LIB_ROOT)

  require 'orientdb-ar'
  require 'rspec'
  #require 'rspec/autorun'
  require 'fileutils'

  TEST_DB_PATH = "#{TEMP_DIR}/test/db_#{rand(999) + 1}"
  puts ">> TEST_DB PATH : #{TEST_DB_PATH}"

  require 'fileutils'
  puts ">> Removing tmp directory #{TEMP_DIR} ..."
  FileUtils.remove_dir TEMP_DIR + '/test', true
  puts ">> Creating OrientDB database..."
  FileUtils.mkdir_p TEST_DB_PATH
  OrientDB::AR::Base.connection = OrientDB::DocumentDatabase.new("local:#{TEST_DB_PATH}/test").create
  puts ">> Connection : #{OrientDB::AR::Base.connection}"

  %w{ person simple_person address phone_number customer flo_admin product invoice_line invoice }.each do |name|
    require SPEC_ROOT + '/models/' + name
  end

  require SPEC_ROOT + '/lint_behavior'

  module Helpers
  end

  RSpec.configure do |config|
    config.include Helpers
    config.include RspecRailsMatchers::Behavior::Lint

    config.color_enabled = true
  end

  SPEC_HELPER_LOADED = true
end