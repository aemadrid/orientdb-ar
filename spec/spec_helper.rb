$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'orientdb-ar'
require 'rspec'
#require 'rspec/autorun'
require 'fileutils'

unless defined?(SPEC_HELPER_LOADED)

  GEM_ROOT     = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LIB_ROOT     = GEM_ROOT + '/lib'
  SPEC_ROOT    = GEM_ROOT + '/spec'
  TEMP_DIR     = GEM_ROOT + '/tmp'

  puts ">> GEM_ROOT     : #{GEM_ROOT}"

  $LOAD_PATH.unshift(LIB_ROOT) unless $LOAD_PATH.include?(LIB_ROOT)

  TEST_DB_PATH = "#{TEMP_DIR}/databases/db_#{rand(999) + 1}"
  puts ">> TEST_DB PATH : #{TEST_DB_PATH}"

  require 'fileutils'
  FileUtils.mkdir_p TEST_DB_PATH
  OrientDB::AR::Base.connection = OrientDB::Database.new("local:#{TEST_DB_PATH}/test").create
  puts ">> Connection : #{OrientDB::AR::Base.connection}"

  class Person < OrientDB::AR::Base
    field :name, :string, :not_null => true
    field :age, :int
    field :tags, [:list, :string]
  end

  module Helpers
  end

  RSpec.configure do |config|
    include Helpers

    config.color_enabled = true
  end

  SPEC_HELPER_LOADED = true
end