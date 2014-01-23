class TestRunner::IO
  class << self
    def input
      @file ||= Kernel.open(File.expand_path('~/.triggertest'), 'r+')
    end

    def run(command, suppress_output = false)
      puts command unless suppress_output
      Kernel.system command
    end

    def read_yaml
      return @yaml if @yaml

      if file?('.test_runner.yaml')
        @yaml = Psych.load_file('.test_runner.yaml')
      else
        @yaml = {}
      end
    end

    def file?(*args)
      File.file?(*args)
    end
  end
end
