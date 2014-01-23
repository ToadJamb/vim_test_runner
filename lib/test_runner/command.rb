class TestRunner::Command
  def initialize(args)
    @file, @line = args.split
  end

  def command
    case File.extname(@file)
    when '.rb'
      "bundle exec rspec #{@file} -l #{@line}"
    when '.feature'
      "bundle exec cucumber #{@file} -l #{@line} -r features"
    when '.lua'
      "lspec #{@file} -l #{@line}"
    end
  end
end
