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

  TEST_URL      = ENV["ORIENTDB_TEST_URL"]
  TEST_USERNAME = ENV["ORIENTDB_TEST_USERNAME"] || 'admin'
  TEST_PASSWORD = ENV["ORIENTDB_TEST_PASSWORD"] || 'admin'
  TEST_POOLED   = ENV["ORIENTDB_TEST_POOLED"].to_s[0, 1].downcase == 't'

  puts "ENV :: TEST_URL : #{TEST_URL} | TEST_USERNAME : #{TEST_USERNAME} | TEST_PASSWORD : #{TEST_PASSWORD} | TEST_POOLED : #{TEST_POOLED}"

  if TEST_URL
    if TEST_POOLED
      puts ">> Testing [#{TEST_URL[0,TEST_URL.index(':')]}] Pooled Database :: TEST_DB URL : #{TEST_URL} : #{TEST_USERNAME} : #{TEST_PASSWORD}"
      OrientDB::AR::Base.connection = OrientDB::DocumentDatabasePool.connect(TEST_URL, TEST_USERNAME, TEST_PASSWORD)
    else
      puts ">> Testing [#{TEST_URL[0,TEST_URL.index(':')]}] Database :: TEST_DB URL : #{TEST_URL} : #{TEST_USERNAME} : #{TEST_PASSWORD}"
      OrientDB::AR::Base.connection = OrientDB::DocumentDatabase.connect(TEST_URL, TEST_USERNAME, TEST_PASSWORD)
    end
  else
    TEST_DB_PATH = "#{TEMP_DIR}/databases/db_#{rand(999) + 1}"
    FileUtils.remove_dir "#{TEMP_DIR}/databases" rescue nil
    FileUtils.mkdir_p TEST_DB_PATH
    puts ">> Testing [local] Database :: TEST_DB PATH : #{TEST_DB_PATH}"
    FileUtils.remove_dir "#{TEMP_DIR}/databases/"
    FileUtils.mkdir_p TEST_DB_PATH
    puts ">> TEST_DB PATH : #{TEST_DB_PATH}"
    OrientDB::AR::Base.connection = OrientDB::DocumentDatabase.new("local:#{TEST_DB_PATH}/test").create
  end

  at_exit do
    puts " [ EXITING ] ".center(120, "~")
    begin
      puts ">> Will close connection ..."
      pp OrientDB::AR::Base.connection
      puts ">> Closing ..."
      OrientDB::AR::Base.connection.close
      puts ">> Closed ..."
    rescue Exception => e
      puts "EXCEPTION: #{e.class.name} : #{e.message}"
      pp e.backtrace
    end
    puts " [ THE END ] ".center(120, "~")
    exit!
  end

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