require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "resque-ranger"
    gem.summary = %Q{Super fast evented and fibered daemon to process resque jobs, some built in job metrics too}
    gem.description = %Q{TODO: Super fast evented and fibered daemon to process resque jobs, some built in job metrics too, just cause your app might not be on 1.9.1, your bot might be able to}
    gem.email = "wbsmith83@gmail.com"
    gem.homepage = "http://github.com/BrianTheCoder/resque-ranger"
    gem.authors = ["brianthecoder"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_dependency "redis", "1.0.4"
    gem.add_dependency "resque", "1.8.0"
    gem.add_dependency "eventmachine", "0.12.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "resque-ranger #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
