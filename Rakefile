require 'rubocop/rake_task'

task :default => [:rubocop]

RuboCop::RakeTask.new do |task|
  task.patterns = ['*.rb']
  task.formatters = ['progress']
end
