require 'rake_tasks'

require 'cane'
require 'rake_tasks/tasks/cane'
require 'rake_tasks/tasks/console'
require 'rake_tasks/tasks/spec'

task :default => []
Rake::Task[:default].clear_prerequisites

task :default => [
  :cane,
  :specs,
]
