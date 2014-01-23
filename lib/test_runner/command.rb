class TestRunner::Command
  def initialize(args)
    @file, @line = args.split
  end

  def command
    "bundle exec rspec #{@file} -l #{@line}" unless @file.empty?
  end
end
