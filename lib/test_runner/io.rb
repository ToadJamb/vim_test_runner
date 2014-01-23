class TestRunner::IO
  class << self
    def input
      @file ||= Kernel.open(File.expand_path('~/.triggertest'), 'r+')
    end

    def run(command, suppress_output = false)
      puts command unless suppress_output
      Kernel.system command
    end
  end
end
