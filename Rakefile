require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  # make sure helper.rb is loaded first, to start simplecov
  test.test_files = FileList['test/helper.rb', 'test/test*.rb']
end

task :default => :test
