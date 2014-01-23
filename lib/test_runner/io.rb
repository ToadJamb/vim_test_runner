class TestRunner::IO
  class << self
    def input
      @file ||= open(File.expand_path('~/.triggertest'), 'r+')
    end

    def run(command)
      puts command
      system command
    end
  end
end
