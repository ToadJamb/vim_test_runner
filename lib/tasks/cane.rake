require 'cane/rake_task'

namespace :cane do
  desc ''
  Cane::RakeTask.new(:quality) do |cane|
    cane.canefile = '.cane'
  end

  desc 'Check abc metrics with cane'
  Cane::RakeTask.new(:warn) do |cane|
    cane.canefile = '.cane'
    cane.abc_max  = 7
    cane.no_doc   = true
    cane.no_style = true
  end

  desc 'Check code quality metrics with cane for all files'
  Cane::RakeTask.new(:all) do |cane|
    cane.canefile = '.cane'
    cane.style_exclude = []
    cane.abc_exclude = []
  end
end

desc 'Run cane to check quality metrics'
task :cane => 'cane:quality'
