require 'cane/rake_task'

namespace :cane do
  def patterns
    "{rakefile,Gemfile,{#{paths}}/**/*.{rb,rake}}"
  end

  def paths
    list = Dir['*/'].map { |d| d[0..-2] }
    list.join ','
  end

  def abc_exclude
    []
  end

  def style_exclude
    []
  end

  desc ''
  Cane::RakeTask.new(:quality) do |cane|
    cane.abc_max = 9
    cane.no_doc  = true

    cane.abc_glob   = patterns
    cane.style_glob = patterns

    cane.style_exclude = style_exclude
    cane.abc_exclude   = abc_exclude
  end

  desc 'Check abc metrics with cane'
  Cane::RakeTask.new(:warn) do |cane|
    cane.abc_max  = 5
    cane.no_doc   = true
    cane.no_style = true

    cane.abc_glob   = patterns
  end

  desc 'Check code quality metrics with cane for all files'
  Cane::RakeTask.new(:all) do |cane|
    cane.abc_max = 9
    cane.no_doc  = true

    cane.abc_glob   = patterns
    cane.style_glob = patterns
  end
end

desc 'Run cane to check quality metrics'
task :cane => 'cane:quality'
