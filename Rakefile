require 'rubygems'
require 'rake'

version = File.exist?('VERSION') ? File.read('VERSION') : ""

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "orientdb-ar"
    gem.platform                  = "jruby"
    gem.authors                   = ["Adrian Madrid"]
    gem.email                     = ["aemadrid@gmail.com"]
    gem.homepage                  = "http://rubygems.org/gems/orientdb"
    gem.summary                   = "ActiveRecord-like persistency through OrientDB in JRuby"
    gem.description               = "Active Model wrappers to persist Ruby objects under OrientDB in JRuby."

    gem.required_rubygems_version = ">= 1.3.6"
    gem.rubyforge_project         = "orientdb-ar"

    gem.add_dependency "orientdb", "0.0.15"
    gem.add_dependency "activemodel", ">= 3.0.3"
    gem.add_development_dependency "awesome_print"
    gem.add_development_dependency "rspec", ">= 2.4"

    gem.files        = `git ls-files`.split("\n")
    gem.test_files   = Dir["test/test*.rb"]
    gem.executables  = `git ls-files`.split("\n").map { |f| f =~ /^bin\/(.*)/ ? $1 : nil }.compact
    gem.require_path = 'lib'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
  end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

desc "Run all examples using rcov"
RSpec::Core::RakeTask.new :rcov => :cleanup_rcov_files do |t|
  t.rcov      = true
  t.rcov_opts = %[-Ilib -Ispec --exclude "spec/*,gems/*" --text-report --sort coverage --aggregate coverage.data]
end

task :cleanup_rcov_files do
  rm_rf 'coverage.data'
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "orientdb #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
