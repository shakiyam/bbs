require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: %i[spec rubocop]

RSpec::Core::RakeTask.new do |task|
  task.rspec_opts = ['-c', '-fd']
  task.pattern    = 'spec/*_spec.rb'
end

RuboCop::RakeTask.new do |task|
  task.patterns = ['*.rb', 'spec/*.rb', 'Rakefile']
  task.formatters = ['progress']
end
